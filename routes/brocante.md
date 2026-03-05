  import { useEffect, useMemo, useState } from 'react'
  import axios from 'axios'
  import { CheckCircleIcon, InfoIcon, UserPlusIcon } from 'lucide-react'
  import { listenCartItems } from '../lib/data'
  import { useAuth } from '../lib/auth'

  const API_BASE_URL = 'http://localhost:5000'
  const EVENT_ID = 'EV-BROCANTE-2026-001'
  const CART_STORAGE_KEY = 'brocante_cart_v2_stands'

  const DEFAULT_CATEGORIE_ID = 'CAT-BROCANTE-2026-STAND'

  type CartItem = {
    brocanteId: string
    brocanteTitle: string
    ownerUid: string
    standId: string
    standLabel: string
    standSize: string
    standPrice: string
    standImage?: string
  }

  type ApiCategory = {
    id: string
    nom_categorie: string
    prix_unitaire: number | string
    currency_code: string
  }

  type EventCategoriesResponse = {
    success: boolean
    categories: ApiCategory[]
  }

  function parseAmount(value: string): number {
    const cleaned = value.replace(/[^0-9,.-]+/g, '').replace(',', '.')
    const parsed = Number.parseFloat(cleaned)
    return Number.isFinite(parsed) ? parsed : 0
  }

  export default function BrocantePayment() {
    const { user, profile } = useAuth()
    const [cartItems, setCartItems] = useState<CartItem[]>([])
    const [resolvedCategorieId, setResolvedCategorieId] = useState<string>('')
    const [resolvedCategorieName, setResolvedCategorieName] = useState<string>('')
    const [isLoadingCategorie, setIsLoadingCategorie] = useState(true)

    const [formData, setFormData] = useState({
      nom: '',
      prenom: '',
      email: '',
      telephone: '',
      message: '',
    })

    const [isSubmitting, setIsSubmitting] = useState(false)
    const [submitStatus, setSubmitStatus] = useState<'idle' | 'success' | 'error'>('idle')
    const [errorMessage, setErrorMessage] = useState('')
    const totalAmount = useMemo(() => cartItems.reduce((sum, item) => sum + parseAmount(item.standPrice), 0), [cartItems])

    const cartBrocantes = useMemo(() => {
      const map = new Map<string, string>()
      for (const item of cartItems) {
        if (!map.has(item.brocanteId)) {
          map.set(item.brocanteId, item.brocanteTitle || item.brocanteId)
        }
      }
      return Array.from(map.entries()).map(([id, title]) => ({ id, title }))
    }, [cartItems])

    useEffect(() => {
      const parseLocalCart = () => {
        try {
          const raw = localStorage.getItem(CART_STORAGE_KEY)
          if (!raw) return []
          const parsed = JSON.parse(raw) as unknown
          if (!Array.isArray(parsed)) return []
          return parsed
            .map((entry) => {
              const obj = entry as Partial<CartItem> | null
              if (!obj || typeof obj !== 'object') return null
              if (!obj.brocanteId || !obj.standId) return null
              return {
                brocanteId: String(obj.brocanteId),
                brocanteTitle: typeof obj.brocanteTitle === 'string' ? obj.brocanteTitle : '',
                ownerUid: typeof obj.ownerUid === 'string' ? obj.ownerUid : '',
                standId: String(obj.standId),
                standLabel: typeof obj.standLabel === 'string' ? obj.standLabel : '',
                standSize: typeof obj.standSize === 'string' ? obj.standSize : '',
                standPrice: typeof obj.standPrice === 'string' ? obj.standPrice : '',
                standImage: typeof obj.standImage === 'string' ? obj.standImage : undefined,
              }
            })
            .filter(Boolean) as CartItem[]
        } catch {
          return []
        }
      }

      if (!user?.uid) {
        setCartItems(parseLocalCart())
        return
      }

      return listenCartItems(
        user.uid,
        (items) => {
          setCartItems(
            items.map((item) => ({
              brocanteId: item.brocanteId,
              brocanteTitle: item.brocanteTitle,
              ownerUid: item.ownerUid,
              standId: item.standId,
              standLabel: item.standLabel,
              standSize: item.standSize,
              standPrice: item.standPrice,
              standImage: item.standImage,
            })),
          )
        },
        () => {
          setCartItems(parseLocalCart())
        },
      )
    }, [user?.uid])

    useEffect(() => {
      if (!profile && !user) return
      setFormData((prev) => {
        const next = { ...prev }
        let changed = false

        if (!next.email && (profile?.email || user?.email)) {
          next.email = profile?.email || user?.email || ''
          changed = true
        }

        if (!next.prenom && profile?.firstName) {
          next.prenom = profile.firstName
          changed = true
        }

        if (!next.nom && profile?.lastName) {
          next.nom = profile.lastName
          changed = true
        }

        if (!next.telephone && profile?.phone) {
          next.telephone = profile.phone
          changed = true
        }

        return changed ? next : prev
      })
    }, [profile, user])

    useEffect(() => {
      let isMounted = true

      const loadCategorie = async () => {
        try {
          setIsLoadingCategorie(true)
          const response = await axios.get<EventCategoriesResponse>(`${API_BASE_URL}/brocante/events/${EVENT_ID}`)
          const categories = Array.isArray(response.data?.categories) ? response.data.categories : []

          const exactMatch = categories.find((category) => category.id === DEFAULT_CATEGORIE_ID)
          const standMatch = categories.find((category) =>
            String(category.nom_categorie || '')
              .toLowerCase()
              .includes('stand'),
          )
          const selected = exactMatch || standMatch || categories[0]

          if (isMounted) {
            setResolvedCategorieId(selected?.id || '')
            setResolvedCategorieName(selected?.nom_categorie || '')
          }
        } catch (error) {
          console.error('[BrocantePayment] chargement categories impossible:', error)
          if (isMounted) {
            setResolvedCategorieId('')
            setResolvedCategorieName('')
          }
        } finally {
          if (isMounted) {
            setIsLoadingCategorie(false)
          }
        }
      }

      loadCategorie()

      return () => {
        isMounted = false
      }
    }, [])


    const handleChange: React.ChangeEventHandler<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement> = (event) => {
      const { name, value } = event.target
      setFormData((prev) => ({ ...prev, [name]: value }))
    }

    const handleSubmit: React.FormEventHandler<HTMLFormElement> = async (event) => {
      event.preventDefault()
      setIsSubmitting(true)
      setErrorMessage('')

      try {
        console.log('[BrocantePayment] soumission declenchee')
        console.log('[BrocantePayment] formulaire', {
          formData,
          cartItems,
          cartBrocantes,
          totalAmount,
          resolvedCategorieId,
          resolvedCategorieName,
        })

        if (!cartItems.length) {
          throw new Error('Votre panier est vide. Ajoutez un stand avant de payer.')
        }

        if (!formData.nom || !formData.prenom || !formData.email || !formData.telephone) {
          throw new Error('Veuillez remplir tous les champs obligatoires')
        }

        if (!resolvedCategorieId) {
          throw new Error('Aucune categorie active trouvee pour cet evenement brocante')
        }

        const montantTotal = totalAmount

        const ticketData = {
          evenement_id: EVENT_ID,
          categorie_id: resolvedCategorieId,
          prenom: formData.prenom,
          nom: formData.nom,
          email: formData.email,
          telephone: formData.telephone,
          quantite: Math.max(cartItems.length, 1),
          montant_total: montantTotal,
          notes_participant: [
            cartBrocantes.length
              ? `Brocantes: ${cartBrocantes.map((item) => `${item.title} (${item.id})`).join(' | ')}`
              : null,
            `Stands: ${cartItems
              .map((item) => `${item.standLabel} | ${item.standSize} | ${item.standPrice} | ${item.brocanteTitle}`)
              .join(' ; ')}`,
            formData.message ? `Message: ${formData.message}` : null,
          ]
            .filter(Boolean)
            .join('\n'),
        }

        console.log('[BrocantePayment] envoi creation billet', ticketData)
        const response = await axios.post(`${API_BASE_URL}/brocante/tickets/create`, ticketData)
        console.log('[BrocantePayment] reponse API', response?.data)

        const billId =
          response.data.data?.bill_id ||
          response.data.bill_id ||
          response.data.e_bill?.bill_id ||
          response.data.data?.e_bill?.bill_id
        const referenceBillet = response.data.data?.reference_billet || response.data.reference_billet

        console.log('🔍 [EXTRACTION] Bill ID extrait:', billId || 'UNDEFINED ❌')
        console.log('🔍 [EXTRACTION] Reference billet:', referenceBillet || 'UNDEFINED ❌')

        const returnUrl = `${window.location.origin}/payment-result?ref=${referenceBillet || ''}`
        
        // 🎯 PORTAIL EBILLING: construire l'URL de redirection vers le portail de paiement
        // Format: https://test.billing-easy.net?invoice={bill_id}&redirect_url={return_url}
        const paymentUrl = billId
          ? `https://test.billing-easy.net?invoice=${billId}&redirect_url=${encodeURIComponent(returnUrl)}`
          : ''

        console.log('[BrocantePayment] paiement construits', {
          billId,
          referenceBillet,
          paymentUrl,
        })

        if (paymentUrl) {
          console.log('═══════════════════════════════════════════════════')
          console.log('🆔 [EBILLING] BILL_ID GENERE:', billId)
          console.log('📋 [EBILLING] REFERENCE BILLET:', referenceBillet)
          console.log('🔗 [EBILLING] URL REDIRECTION:', paymentUrl)
          console.log('═══════════════════════════════════════════════════')
          console.log('[BrocantePayment] redirection dans 3s...')
          await new Promise((resolve) => setTimeout(resolve, 3000))
          window.location.href = paymentUrl
          return
        }

        console.error('❌❌❌ [EBILLING] ERREUR: AUCUN BILL_ID RECUPERE ❌❌❌')
        console.error('📦 Response complète:', JSON.stringify(response.data, null, 2))
        throw new Error('Impossible de recuperer l\'URL de paiement Ebilling')
      } catch (error: any) {
        console.error('Erreur paiement brocante:', error)
        setSubmitStatus('error')
        setErrorMessage(error.response?.data?.error || error.message || 'Une erreur est survenue')
        setTimeout(() => {
          setSubmitStatus('idle')
          setErrorMessage('')
        }, 5000)
      } finally {
        setIsSubmitting(false)
      }
    }

    return (
      <div className="w-full">
        <div className="relative bg-gradient-to-br from-[#01579B] via-[#0277BD] to-black text-white py-16">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h1 className="text-4xl md:text-5xl font-bold mb-4">Inscription Brocante</h1>
            <p className="text-lg text-blue-100">
              Reservez votre stand et payez en toute securite
            </p>
          </div>
        </div>

        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="bg-white rounded-2xl shadow-xl p-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
              <UserPlusIcon className="w-7 h-7 mr-3 text-[#01579B]" />
              Formulaire de paiement
            </h2>

            {submitStatus === 'success' && (
              <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg">
                <p className="text-green-800 font-semibold flex items-center">
                  <CheckCircleIcon className="w-5 h-5 mr-2" />
                  Paiement initie avec succes.
                </p>
              </div>
            )}

            {submitStatus === 'error' && (
              <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
                <p className="text-red-800 font-semibold flex items-center">
                  <InfoIcon className="w-5 h-5 mr-2" />
                  {errorMessage || 'Une erreur est survenue. Veuillez reessayer.'}
                </p>
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="rounded-2xl border border-black/10 bg-[#f8fbff] p-4">
                <div className="text-sm font-semibold text-gray-700">Recap panier</div>
                {cartItems.length ? (
                  <div className="mt-3 space-y-2 text-sm text-gray-700">
                    {cartItems.map((item) => (
                      <div key={`${item.brocanteId}__${item.standId}`} className="flex items-center justify-between gap-3">
                        <div className="min-w-0">
                          <div className="font-semibold truncate">{item.standLabel}</div>
                          <div className="text-xs text-gray-500 truncate">
                            {item.brocanteTitle} - {item.standSize}
                          </div>
                        </div>
                        <div className="shrink-0 font-semibold">{item.standPrice}</div>
                      </div>
                    ))}
                    <div className="flex items-center justify-between border-t border-black/10 pt-2">
                      <span className="font-semibold">Total</span>
                      <span className="font-semibold">{totalAmount.toLocaleString('fr-FR')} XAF</span>
                    </div>
                  </div>
                ) : (
                  <p className="mt-2 text-sm text-gray-600">Panier vide. Ajoutez un stand depuis la page publique.</p>
                )}
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label htmlFor="nom" className="block text-sm font-semibold text-gray-700 mb-2">
                    Nom *
                  </label>
                  <input
                    type="text"
                    id="nom"
                    name="nom"
                    value={formData.nom}
                    onChange={handleChange}
                    required
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent"
                    placeholder="Votre nom"
                  />
                </div>
                <div>
                  <label htmlFor="prenom" className="block text-sm font-semibold text-gray-700 mb-2">
                    Prenom *
                  </label>
                  <input
                    type="text"
                    id="prenom"
                    name="prenom"
                    value={formData.prenom}
                    onChange={handleChange}
                    required
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent"
                    placeholder="Votre prenom"
                  />
                </div>
                <div>
                  <label htmlFor="email" className="block text-sm font-semibold text-gray-700 mb-2">
                    Email *
                  </label>
                  <input
                    type="email"
                    id="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    required
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent"
                    placeholder="vous@email.com"
                  />
                </div>
                <div>
                  <label htmlFor="telephone" className="block text-sm font-semibold text-gray-700 mb-2">
                    Telephone *
                  </label>
                  <input
                    type="tel"
                    id="telephone"
                    name="telephone"
                    value={formData.telephone}
                    onChange={handleChange}
                    required
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent"
                    placeholder="077000000"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Brocantes du panier</label>
                <div className="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-50 text-sm text-gray-700">
                  {cartBrocantes.length
                    ? cartBrocantes.map((item) => `${item.title} (${item.id})`).join(' | ')
                    : 'Aucune brocante detectee'}
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label htmlFor="montant" className="block text-sm font-semibold text-gray-700 mb-2">
                    Montant total
                  </label>
                  <input
                    type="text"
                    id="montant"
                    name="montant"
                    value={`${totalAmount.toLocaleString('fr-FR')} XAF`}
                    readOnly
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-50"
                  />
                </div>
                <div>
                  <label htmlFor="categorie" className="block text-sm font-semibold text-gray-700 mb-2">
                    Categorie de paiement
                  </label>
                  <input
                    type="text"
                    id="categorie"
                    name="categorie"
                    value={isLoadingCategorie ? 'Chargement...' : resolvedCategorieName || 'Non trouvee'}
                    readOnly
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-50"
                  />
                </div>
              </div>

              <div>
                <label htmlFor="message" className="block text-sm font-semibold text-gray-700 mb-2">
                  Message
                </label>
                <textarea
                  id="message"
                  name="message"
                  value={formData.message}
                  onChange={handleChange}
                  rows={4}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent resize-none"
                />
              </div>

              <button
                type="submit"
                disabled={isSubmitting || !cartItems.length || isLoadingCategorie || !resolvedCategorieId}
                className="w-full px-8 py-4 bg-[#01579B] text-white rounded-lg font-bold text-lg hover:bg-blue-800 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
              >
                {isSubmitting ? (
                  <>
                    <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                    <span>Paiement en cours...</span>
                  </>
                ) : (
                  <>
                    <UserPlusIcon className="w-5 h-5" />
                    <span>Confirmer et payer</span>
                  </>
                )}
              </button>

              <p className="text-center text-sm text-gray-600">
                Paiement securise via Ebilling - AirtelMoney, Moov Money acceptes
              </p>
            </form>
          </div>
        </div>
      </div>
    )
  }