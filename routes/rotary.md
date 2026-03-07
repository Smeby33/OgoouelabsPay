import React, { useState, useEffect } from 'react';
import { MessageCircleIcon, PhoneIcon, MapPinIcon, CalendarIcon, UsersIcon, ClockIcon, UserPlusIcon, CheckCircleIcon, InfoIcon, HeartIcon, ArrowRightIcon, DownloadIcon, FileTextIcon, ContactIcon } from 'lucide-react';
import DroitsInscription from './DroitsInscription';
import axios from 'axios';

// Configuration API
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';
const EVENT_ID = 'EV-ROTARY-FORUM-2026';

// Mapping qualité -> catégorie_id
const CATEGORY_MAPPING: Record<string, { id: string; prix: number }> = {
  rotarien: { id: 'CAT-FORUM-2026-ROTARIEN', prix: 40000 },
  rotaractien: { id: 'CAT-FORUM-2026-ROTARACTIEN', prix: 30000 },
  invite: { id: 'CAT-FORUM-2026-INVITE', prix: 35000 }
};

const ACTIVITY_MAPPING: Record<string, { id: string; prix: number }> = {
  'Excursion Omboué': { id: 'CAT-FORUM-2026-EXCURSION', prix: 30000 },
  'POG TOUR': { id: 'CAT-FORUM-2026-POG-TOUR', prix: 20000 }
};

export function Contact() {
  const [currentView, setCurrentView] = useState<'contact' | 'droits'>('contact');
  const [formData, setFormData] = useState({
    name: '',
    prenom: '',
    email: '',
    phone: '',
    club: '',
    function: '',
    qualite: 'rotarien',
    accommodation: 'none',
    activite: 'none',
    message: ''
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<'idle' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState('');
  const [totalAmount, setTotalAmount] = useState(0);

  // Calculer le montant total
  useEffect(() => {
    let total = 0;
    
    // Prix de base selon la qualité
    if (formData.qualite && CATEGORY_MAPPING[formData.qualite]) {
      total += CATEGORY_MAPPING[formData.qualite].prix;
    }
    
    // Prix activité optionnelle
    if (formData.activite !== 'none' && ACTIVITY_MAPPING[formData.activite]) {
      total += ACTIVITY_MAPPING[formData.activite].prix;
    }
    
    setTotalAmount(total);
  }, [formData.qualite, formData.activite]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setErrorMessage('');
    
    try {
      // Validation
      if (!formData.name || !formData.prenom || !formData.email || !formData.phone || !formData.club) {
        throw new Error('Veuillez remplir tous les champs obligatoires');
      }

      // Récupérer la catégorie selon la qualité
      const category = CATEGORY_MAPPING[formData.qualite];
      if (!category) {
        throw new Error('Qualité invalide');
      }

      // Préparer les données pour l'API
      const ticketData = {
        evenement_id: EVENT_ID,
        categorie_id: category.id,
        prenom: formData.prenom,
        nom: formData.name,
        email: formData.email,
        telephone: formData.phone,
        quantite: 1,
        notes_participant: `Club: ${formData.club}\nHébergement: ${formData.accommodation}\nActivité: ${formData.activite}\n${formData.message}`
      };

      console.log('📤 Envoi des données:', ticketData);

      // Appeler l'API de création de billet
      const response = await axios.post(`${API_BASE_URL}/rotary/tickets/create`, ticketData);

      console.log('✅ Réponse API:', response.data);

      if (response.data.success && response.data.payment_url) {
        // Rediriger vers la page de paiement Ebilling
        console.log('🔗 Redirection vers:', response.data.payment_url);
        window.location.href = response.data.payment_url;
      } else {
        throw new Error('Erreur lors de la création du billet');
      }

    } catch (error: any) {
      console.error('❌ Erreur:', error);
      setIsSubmitting(false);
      setSubmitStatus('error');
      setErrorMessage(error.response?.data?.error || error.message || 'Une erreur est survenue');
      
      setTimeout(() => {
        setSubmitStatus('idle');
        setErrorMessage('');
      }, 5000);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const forumInfo = [
    {
      icon: CalendarIcon,
      title: 'Dates du Forum',
      content: '20-22 Février 2026',
      subtitle: '3 jours d\'enrichissement'
    },
    {
      icon: MapPinIcon,
      title: 'Lieu',
      content: 'Canal Olympia, Port-Gentil',
      subtitle: 'Espace vente disponible'
    },
    {
      icon: UsersIcon,
      title: 'Participants',
      content: 'Tous les Clubs Rotary',
      subtitle: 'Membres et invités bienvenus'
    },
    {
      icon: ClockIcon,
      title: 'Programme',
      content: 'Conférences & Ateliers',
      subtitle: 'Excursion à Omboué incluse'
    }
  ];

  const registrationSteps = [
    {
      step: 1,
      title: 'Inscription WhatsApp',
      description: 'Rejoignez notre groupe WhatsApp officiel pour recevoir toutes les informations en temps réel',
      action: 'Rejoindre le Groupe'
    },
    {
      step: 2,
      title: 'Formulaire Complet',
      description: 'Remplissez le formulaire ci-dessous avec toutes vos informations',
      action: 'Remplir le Formulaire'
    },
    {
      step: 3,
      title: 'Confirmation',
      description: 'Nous vous contacterons pour confirmer votre inscription et vous donner les détails pratiques',
      action: 'Attendre la Confirmation'
    }
  ];

  return (
    <div className="w-full">
      {/* Navigation Tabs */}
      <div className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <nav className="flex justify-center space-x-8">
            <button
              onClick={() => setCurrentView('contact')}
              className={`py-4 px-6 border-b-2 font-medium text-lg flex items-center space-x-2 ${
                currentView === 'contact'
                  ? 'border-[#f7a81b] text-[#f7a81b]'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <ContactIcon className="w-5 h-5" />
              <span>Contact & Inscription</span>
            </button>
            <button
              onClick={() => setCurrentView('droits')}
              className={`py-4 px-6 border-b-2 font-medium text-lg flex items-center space-x-2 ${
                currentView === 'droits'
                  ? 'border-[#f7a81b] text-[#f7a81b]'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <FileTextIcon className="w-5 h-5" />
              <span>Droits d'Inscription</span>
            </button>
          </nav>
        </div>
      </div>

      {/* Content based on selected view */}
      {(() => {
        switch (currentView) {
          case 'droits':
            return <DroitsInscription />;
          case 'contact':
          default:
            return (
              <>
                {/* Hero Section */}
                <div className="relative bg-gradient-to-br from-[#0277BD] via-black to-black text-white py-20 overflow-hidden">
        <div className="absolute inset-0">
          <img 
            src="/un-etudiant-en-medecine-noir-en-peignoir-fait-des-recherches-et-prend-des-notes-pour-sa-these.jpg"
            alt="Affiche officielle 22ème Forum des Clubs Rotary - Inscription" 
            className="w-full h-full object-cover opacity-20" 
          />
        </div>
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="text-5xl font-bold mb-6">Inscription Forum 2026</h1>
          <p className="text-xl text-blue-100 mx-auto mb-6">
            Rejoignez-nous pour le 22ème Forum des Clubs Rotary
          </p>
          <div className="text-2xl font-bold text-[#F9A825] italic">
            "Unis pour Faire le Bien et Donner du Bonheur Ensemble et Autrement"
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        {/* Inscription WhatsApp Mise en Avant */}
        

        {/* Étapes d'inscription */}
        <div className="mb-16">
          <h2 className="text-3xl font-bold text-gray-900 text-center mb-12">
            Comment S'inscrire en 3 Étapes
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {registrationSteps.map((step, index) => (
              <div key={index} className="relative">
                <div className="bg-white rounded-2xl shadow-xl p-8 text-center h-full">
                  <div className="w-16 h-16 bg-[#F9A825] text-blue-900 rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-6">
                    {step.step}
                  </div>
                  <h3 className="text-xl font-bold text-gray-900 mb-4">{step.title}</h3>
                  <p className="text-gray-600 mb-6 leading-relaxed">{step.description}</p>
                  <div className="inline-flex items-center text-[#01579B] font-semibold">
                    <CheckCircleIcon className="w-5 h-5 mr-2" />
                    {step.action}
                  </div>
                </div>
                {index < registrationSteps.length - 1 && (
                  <div className="hidden md:block absolute top-1/2 -right-4 transform -translate-y-1/2">
                    <ArrowRightIcon className="w-8 h-8 text-[#F9A825]" />
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-12 mb-16">
          {/* Formulaire d'inscription */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-2xl shadow-xl p-8">
              <h2 className="text-3xl font-bold text-gray-900 mb-6 flex items-center">
                <UserPlusIcon className="w-8 h-8 mr-3 text-[#01579B]" />
                Formulaire d'Inscription
              </h2>
              
              {submitStatus === 'success' && (
                <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg">
                  <p className="text-green-800 font-semibold flex items-center">
                    <CheckCircleIcon className="w-5 h-5 mr-2" />
                    Inscription enregistrée avec succès ! Nous vous contacterons bientôt.
                  </p>
                </div>
              )}

              {submitStatus === 'error' && (
                <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
                  <p className="text-red-800 font-semibold flex items-center">
                    <InfoIcon className="w-5 h-5 mr-2" />
                    {errorMessage || 'Une erreur est survenue. Veuillez réessayer.'}
                  </p>
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label htmlFor="name" className="block text-sm font-semibold text-gray-700 mb-2">
                      Nom Complet *
                    </label>
                    <input 
                      type="text" 
                      id="name" 
                      name="name" 
                      value={formData.name} 
                      onChange={handleChange} 
                      required 
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent" 
                      placeholder="Votre nom complet" 
                    />
                  </div>prenom
                  <div>
                    <label htmlFor="prenom" className="block text-sm font-semibold text-gray-700 mb-2">
                      Prénom *
                    </label>
                    <input 
                      type="text" 
                      id="prenom" 
                      name="prenom" 
                      value={formData.name} 
                      onChange={handleChange} 
                      required 
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent" 
                      placeholder="Votre prénom" 
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
                      placeholder="votre@email.com" 
                    />
                  </div>
                  <div>
                    <label htmlFor="phone" className="block text-sm font-semibold text-gray-700 mb-2">
                      Téléphone *
                    </label>
                    <input 
                      type="tel" 
                      id="phone" 
                      name="phone" 
                      value={formData.phone} 
                      onChange={handleChange} 
                      required 
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent" 
                      placeholder="+241 XX XX XX XX" 
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label htmlFor="qualite" className="block text-sm font-semibold text-gray-700 mb-2">
                      Qualité *
                    </label>
                    <select 
                      id="qualite" 
                      name="qualite" 
                      value={formData.qualite} 
                      onChange={handleChange} 
                      required
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent"
                    >
                      <option value="rotarien">Rotarien  (40 000 F) </option>
                      <option value="rotaractien">Rotaractien  (30 000 F) </option>
                      <option value="invite">Invité  (35 000 F) </option>
                    </select>
                  </div>
                  <div>
                    <label htmlFor="club" className="block text-sm font-semibold text-gray-700 mb-2">
                      Club *
                    </label>
                    <select 
                      id="club" 
                      name="club" 
                      value={formData.club} 
                      onChange={handleChange} 
                      required 
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent"
                    >
                      <option value="">Sélectionnez votre club</option>
                      <optgroup label="ROTARY CLUBS DU GABON">
                        <option value="ROTARY CLUB LIBREVILLE DOYEN">ROTARY CLUB LIBREVILLE DOYEN</option>
                        <option value="ROTARY CLUB PORT-GENTIL">ROTARY CLUB PORT-GENTIL</option>
                        <option value="ROTARY CLUB LIBREVILLE OKOUME">ROTARY CLUB LIBREVILLE OKOUME</option>
                        <option value="ROTARY CLUB PORT-GENTIL OZOURI">ROTARY CLUB PORT-GENTIL OZOURI</option>
                        <option value="ROTARY CLUB LIBREVILLE KOMO">ROTARY CLUB LIBREVILLE KOMO</option>
                        <option value="ROTARY CLUB LIBREVILLE MONDAH">ROTARY CLUB LIBREVILLE MONDAH</option>
                        <option value="ROTARY CLUB LIBREVILLE MONTS DE CRISTAL">ROTARY CLUB LIBREVILLE MONTS DE CRISTAL</option>
                        <option value="ROTARY CLUB LIBREVILLE CENTRE">ROTARY CLUB LIBREVILLE CENTRE</option>
                        <option value="ROTARY CLUB LIBREVILLE AKANDA">ROTARY CLUB LIBREVILLE AKANDA</option>
                        <option value="ROTARY CLUB LIBREVILLE SUD">ROTARY CLUB LIBREVILLE SUD</option>
                        <option value="ROTARY CLUB LIBREVILLE BANTOU">ROTARY CLUB LIBREVILLE BANTOU</option>
                      </optgroup>
                      <optgroup label="ROTARACT CLUBS DU GABON">
                        <option value="ROTARACT CLUB LIBREVILLE DOYEN">ROTARACT CLUB LIBREVILLE DOYEN</option>
                        <option value="ROTARACT CLUB PORT-GENTIL OZOURI">ROTARACT CLUB PORT-GENTIL OZOURI</option>
                        <option value="ROTARACT CLUB PORT-GENTIL">ROTARACT CLUB PORT-GENTIL</option>
                        <option value="ROTARACT CLUB LIBREVILLE MONTS DE CRISTAL">ROTARACT CLUB LIBREVILLE MONTS DE CRISTAL</option>
                        <option value="ROTARACT CLUB LIBREVILLE KOMO">ROTARACT CLUB LIBREVILLE KOMO</option>
                        <option value="ROTARACT CLUB LIBREVILLE AKANDA">ROTARACT CLUB LIBREVILLE AKANDA</option>
                        <option value="ROTARACT CLUB LIBREVILLE SUD">ROTARACT CLUB LIBREVILLE SUD</option>
                        <option value="ROTARACT CLUB LIBREVILLE BANTOU">ROTARACT CLUB LIBREVILLE BANTOU</option>
                      </optgroup>
                      <optgroup label="INTERACT CLUBS DU GABON">
                        <option value="INTERACT CLUB LIBREVILLE DOYEN">INTERACT CLUB LIBREVILLE DOYEN</option>
                      </optgroup>
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  
                  <div>
                    <label htmlFor="accommodation" className="block text-sm font-semibold text-gray-700 mb-2">
                      Hébergement
                    </label>
                    <select 
                      id="accommodation" 
                      name="accommodation" 
                      value={formData.accommodation} 
                      onChange={handleChange} 
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent"
                    >
                      <option value="none">Pas d'hébergement</option>
                      <option value="external">Hébergement externe</option>
                      <optgroup label="Hôtels 4 étoiles">
                        <option value="Hôtel TARA-ME">Hôtel TARA-ME </option>
                        <option value="Hôtel MANDJI LOISIRS">Hôtel MANDJI LOISIRS </option>
                        <option value="Hôtel CHEZ JIMMY">Hôtel CHEZ JIMMY </option>
                        <option value="Hôtel HIBISCUS">Hôtel HIBISCUS </option>
                        <option value="Hôtel DU PARC">Hôtel DU PARC </option>
                        <option value="Hôtel MANDJI">Hôtel MANDJI - Ancien Méridien</option>
                        <option value="Hôtel ISIS">Hôtel ISIS </option>
                        <option value="Hôtel LE BOUGAINVILLIER">Hôtel LE BOUGAINVILLIER</option>
                        <option value="RÉSIDENCE YASMANNI">RÉSIDENCE YASMANNI </option>
                      </optgroup>
                      <optgroup label="Hôtels 3 étoiles">
                        <option value="Hôtel OPHELIA LODGE">Hôtel OPHELIA LODGE </option>
                        <option value="Hôtel LE BAMBOU">Hôtel LE BAMBOU </option>
                        <option value="Hôtel LE RANCH">Hôtel LE RANCH</option>
                        <option value="Hôtel SICKA">Hôtel SICKA </option>
                        <option value="LE GUI">LE GUI </option>
                        <option value="LE PRINTEMPS">LE PRINTEMPS </option>
                        <option value="ERING PALACE">ERING PALACE </option>
                      </optgroup>
                      <optgroup label="Hôtels 2 étoiles">
                        <option value="CHEZ OLLA">CHEZ OLLA </option>
                      </optgroup>
                    </select>
                  </div>
                  <div>
                    <label htmlFor="activite" className="block text-sm font-semibold text-gray-700 mb-2">
                      Activité optionnelle
                    </label>
                    <select 
                      id="activite" 
                      name="activite" 
                      value={formData.activite} 
                      onChange={handleChange} 
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01579B] focus:border-transparent"
                    >
                      <option value="none">Pas d'activité</option>
                      <option value="Excursion Omboué">Excursion Omboué (30 000 F)</option>
                      <option value="POG TOUR">POG TOUR (20 000 F)</option>
                    </select>
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
                    onChange={handleChange}  flex-1">
                      <h3 className="text-xl font-bold text-gray-900 mb-2">
                        Paiement Mobile et Numérique
                      </h3>
                      <p className="text-gray-600 mb-3">
                        Options de paiement sécurisées disponibles
                      </p>
                      {totalAmount > 0 && (
                        <div className="bg-white rounded-lg p-4 inline-block">
                          <p className="text-sm text-gray-600 mb-1">Montant total à payer :</p>
                          <p className="text-3xl font-bold text-[#01579B]">
                            {totalAmount.toLocaleString('fr-FR')} FCFA
                          </p>
                          {formData.activite !== 'none' && (
                            <p className="text-xs text-gray-500 mt-2">
                              Inscription + {formData.activite}
                            </p>
                          )}
                        </div>
                      )}n Paiement Mobile */}
                <div className="bg-gradi || totalAmount === 0} 
                  className="w-full px-8 py-4 bg-[#01579B] text-white rounded-lg font-bold text-lg hover:bg-blue-800 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
                >
                  {isSubmitting ? (
                    <>
                      <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      <span>Traitement en cours...</span>
                    </>
                  ) : (
                    <>
                      <UserPlusIcon className="w-5 h-5" />
                      <span>Procéder au paiement ({totalAmount.toLocaleString('fr-FR')} FCFA)</span>
                    </>
                  )}
                </button>
                
                <p className="text-center text-sm text-gray-600">
                  🔒 Paiement sécurisé via Ebilling - Tmoney, Flooz, Moov Money acceptés
                </pclassName="h-20 w-auto object-contain"
                      />
                    </div>
                  </div>
                </div>

                <button 
                  type="submit" 
                  disabled={isSubmitting} 
                  className="w-full px-8 py-4 bg-[#01579B] text-white rounded-lg font-bold text-lg hover:bg-blue-800 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
                >
                  {isSubmitting ? (
                    <>
                      <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      <span>Inscription en cours...</span>
                    </>
                  ) : (
                    <>
                      <UserPlusIcon className="w-5 h-5" />
                      <span>Confirmation et paiement</span>
                    </>
                  )}
                </button>
              </form>
            </div>
          </div>

          
        </div>

        {/* CTA Final */}
        <div className="bg-gradient-to-br from-gray-50 to-blue-50 rounded-3xl p-8 md:p-12">
          <div className="max-w-4xl mx-auto">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-center">
              <div className="lg:col-span-2 text-center lg:text-left">
                <h2 className="text-3xl font-bold text-gray-900 mb-4 flex items-center justify-center lg:justify-start">
                  <HeartIcon className="w-8 h-8 text-red-500 mr-3" />
                  Une Expérience Inoubliable Vous Attend
                </h2>
                <p className="text-gray-700 text-lg mb-8">
                  Rejoignez des centaines de Rotariens pour trois jours d'apprentissage, 
                  de partage et de communion fraternelle dans un cadre exceptionnel
                </p>
                <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
                  <a 
                    href="https://chat.whatsapp.com/KDs6kOA3qYhEsMHOY7ei0o?mode=wwt"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="px-8 py-4 bg-green-600 text-white rounded-lg font-bold text-lg hover:bg-green-700 transition-colors flex items-center justify-center"
                  >
                    <MessageCircleIcon className="w-5 h-5 mr-2" />
                    Inscription WhatsApp
                  </a>
                  <a 
                    href="/program" 
                    className="px-8 py-4 bg-white text-[#01579B] border-2 border-[#01579B] rounded-lg font-bold text-lg hover:bg-gray-50 transition-colors"
                  >
                    Voir le Programme
                  </a>
                  <a 
                    href="/PROMO-22EME-FORUM-DES-CLUBS-PORT-GENTIL-2026.pdf"
                    download="Programme-Forum-Rotary-2026.pdf"
                    className="px-8 py-4 bg-[#F9A825] text-blue-900 rounded-lg font-bold text-lg hover:bg-[#FBC02D] transition-colors flex items-center justify-center"
                  >
                    <DownloadIcon className="w-5 h-5 mr-2" />
                    Télécharger PDF
                  </a>
                </div>
              </div>
              
              {/* Code QR alternatif */}
              <div className="text-center">
                <div className="bg-white p-6 rounded-2xl shadow-lg">
                  <p className="text-gray-800 font-semibold mb-4">Accès direct aux inscriptions :</p>
                  <img 
                    src={`https://api.qrserver.com/v1/create-qr-code/?size=140x140&data=${encodeURIComponent('https://chat.whatsapp.com/KDs6kOA3qYhEsMHOY7ei0o?mode=wwt')}`}
                    alt="Code QR inscription Forum 2026"
                    className="w-35 h-35 mx-auto"
                  />
                  <p className="text-gray-600 text-sm mt-3">Rejoindre via QR</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
              </>
            );
        }
      })()}
    </div>
  );
}



const EBILLING_USERNAME ='afup';
const EBILLING_SHARED_KEY ='b3b8814e-4639-46a1-97c3-bf37401dc54b';
const EBILLING_URL = 'https://lab.billing-easy.net/api/v1/merchant/e_bills';

  staging.billing-easy.net


