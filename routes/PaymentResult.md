import React, { useState, useEffect } from 'react';
import { 
  CheckCircleIcon, 
  XCircleIcon, 
  ClockIcon,
  DownloadIcon,
  MailIcon,
  CalendarIcon,
  MapPinIcon,
  TicketIcon,
  RefreshCwIcon,
  HomeIcon
} from 'lucide-react';
import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

export function PaymentResult() {
  const [ticketData, setTicketData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  // Récupérer la référence depuis l'URL
  const urlParams = new URLSearchParams(window.location.search);
  const reference = urlParams.get('ref');

  useEffect(() => {
    if (reference) {
      checkPaymentStatus();
      // Vérifier le statut toutes les 3 secondes si en attente
      const interval = setInterval(() => {
        if (ticketData?.statut_paiement === 'en_attente') {
          checkPaymentStatus();
        }
      }, 3000);
      
      return () => clearInterval(interval);
    }
  }, [reference, ticketData?.statut_paiement]);

  const checkPaymentStatus = async () => {
    try {
      const response = await axios.get(`${API_URL}/rotary/tickets/${reference}`);
      setTicketData(response.data.ticket);
      setIsLoading(false);
    } catch (err: any) {
      console.error('Erreur:', err);
      setError(err.response?.data?.error || 'Erreur lors de la vérification');
      setIsLoading(false);
    }
  };

  const downloadQRCode = () => {
    if (ticketData?.qr_code_url) {
      const link = document.createElement('a');
      link.href = ticketData.qr_code_url;
      link.download = `Billet-${ticketData.reference_billet}.png`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  };

  const printTicket = () => {
    window.print();
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-blue-100 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full text-center">
          <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <h2 className="text-xl font-bold text-gray-900 mb-2">Vérification du paiement...</h2>
          <p className="text-gray-600">Veuillez patienter</p>
        </div>
      </div>
    );
  }

  if (error || !ticketData) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-red-50 to-red-100 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full text-center">
          <XCircleIcon className="w-20 h-20 text-red-500 mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Billet introuvable</h2>
          <p className="text-gray-600 mb-6">{error || 'Référence invalide'}</p>
          <button
            onClick={() => window.location.href = '/'}
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors inline-flex items-center"
          >
            <HomeIcon className="w-5 h-5 mr-2" />
            Retour à l'accueil
          </button>
        </div>
      </div>
    );
  }

  const isPaid = ticketData.statut_paiement === 'paye';
  const isPending = ticketData.statut_paiement === 'en_attente';
  const isFailed = ticketData.statut_paiement === 'echoue';

  return (
    <div className={`min-h-screen print:bg-white ${
      isPaid ? 'bg-gradient-to-br from-green-50 to-green-100' :
      isPending ? 'bg-gradient-to-br from-yellow-50 to-yellow-100' :
      'bg-gradient-to-br from-red-50 to-red-100'
    } py-8 px-4`}>
      <div className="max-w-3xl mx-auto">
        {/* Header avec statut */}
        <div className="bg-white rounded-2xl shadow-2xl overflow-hidden mb-6 print:shadow-none">
          <div className={`${
            isPaid ? 'bg-gradient-to-r from-green-500 to-green-600' :
            isPending ? 'bg-gradient-to-r from-yellow-500 to-yellow-600' :
            'bg-gradient-to-r from-red-500 to-red-600'
          } p-8 text-white text-center`}>
            {isPaid && (
              <>
                <CheckCircleIcon className="w-20 h-20 mx-auto mb-4 animate-bounce" />
                <h1 className="text-3xl font-bold mb-2">Paiement Confirmé ! 🎉</h1>
                <p className="text-lg opacity-90">Votre billet a été envoyé par email</p>
              </>
            )}
            {isPending && (
              <>
                <ClockIcon className="w-20 h-20 mx-auto mb-4 animate-pulse" />
                <h1 className="text-3xl font-bold mb-2">Paiement en cours...</h1>
                <p className="text-lg opacity-90">Vérification en cours, veuillez patienter</p>
              </>
            )}
            {isFailed && (
              <>
                <XCircleIcon className="w-20 h-20 mx-auto mb-4" />
                <h1 className="text-3xl font-bold mb-2">Paiement échoué</h1>
                <p className="text-lg opacity-90">Une erreur s'est produite lors du paiement</p>
              </>
            )}
          </div>

          {/* Détails du billet */}
          <div className="p-8">
            <div className="mb-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">
                {ticketData.evenement_titre}
              </h2>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                <div className="flex items-start space-x-3">
                  <CalendarIcon className="w-5 h-5 text-blue-600 mt-1" />
                  <div>
                    <p className="text-sm text-gray-500">Date de l'événement</p>
                    <p className="font-semibold text-gray-900">
                      {new Date(ticketData.date_evenement).toLocaleDateString('fr-FR', {
                        weekday: 'long',
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric'
                      })}
                    </p>
                  </div>
                </div>

                <div className="flex items-start space-x-3">
                  <MapPinIcon className="w-5 h-5 text-blue-600 mt-1" />
                  <div>
                    <p className="text-sm text-gray-500">Lieu</p>
                    <p className="font-semibold text-gray-900">{ticketData.lieu}</p>
                  </div>
                </div>

                <div className="flex items-start space-x-3">
                  <TicketIcon className="w-5 h-5 text-blue-600 mt-1" />
                  <div>
                    <p className="text-sm text-gray-500">Référence du billet</p>
                    <p className="font-mono font-bold text-blue-600">
                      {ticketData.reference_billet}
                    </p>
                  </div>
                </div>

                <div className="flex items-start space-x-3">
                  <MailIcon className="w-5 h-5 text-blue-600 mt-1" />
                  <div>
                    <p className="text-sm text-gray-500">Email</p>
                    <p className="font-semibold text-gray-900">{ticketData.email}</p>
                  </div>
                </div>
              </div>

              {/* Informations du participant */}
              <div className="bg-blue-50 rounded-xl p-6 mb-6">
                <h3 className="font-bold text-gray-900 mb-3">Informations du participant</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-600">Nom complet</p>
                    <p className="font-semibold text-gray-900">
                      {ticketData.prenom} {ticketData.nom}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Catégorie</p>
                    <p className="font-semibold text-gray-900">{ticketData.nom_categorie}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Quantité</p>
                    <p className="font-semibold text-gray-900">{ticketData.quantite} place(s)</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Montant payé</p>
                    <p className="font-bold text-green-600 text-lg">
                      {ticketData.montant_total.toLocaleString('fr-FR')} {ticketData.currency_code}
                    </p>
                  </div>
                </div>
              </div>

              {/* QR Code (seulement si payé) */}
              {isPaid && ticketData.qr_code_url && (
                <div className="bg-gradient-to-br from-blue-50 to-purple-50 rounded-xl p-6 text-center">
                  <h3 className="font-bold text-gray-900 mb-4 text-lg">
                    Votre QR Code d'Accès
                  </h3>
                  <div className="bg-white rounded-xl p-6 inline-block shadow-lg">
                    <img 
                      src={ticketData.qr_code_url} 
                      alt="QR Code" 
                      className="w-64 h-64 mx-auto"
                    />
                  </div>
                  <p className="text-sm text-gray-600 mt-4 mb-4">
                    Présentez ce QR code à l'entrée de l'événement
                  </p>
                  <div className="flex justify-center gap-3 print:hidden">
                    <button
                      onClick={downloadQRCode}
                      className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors inline-flex items-center"
                    >
                      <DownloadIcon className="w-4 h-4 mr-2" />
                      Télécharger
                    </button>
                    <button
                      onClick={printTicket}
                      className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
                    >
                      🖨️ Imprimer
                    </button>
                  </div>
                </div>
              )}

              {/* Notes du participant */}
              {ticketData.notes_participant && (
                <div className="bg-gray-50 rounded-xl p-6 mt-6">
                  <h3 className="font-bold text-gray-900 mb-2">Vos notes</h3>
                  <p className="text-gray-700 whitespace-pre-wrap">
                    {ticketData.notes_participant}
                  </p>
                </div>
              )}

              {/* Message de statut */}
              {isPending && (
                <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4 mt-6 flex items-start">
                  <RefreshCwIcon className="w-5 h-5 text-yellow-600 mr-3 mt-0.5 animate-spin" />
                  <div>
                    <p className="font-semibold text-yellow-800">Paiement en cours de traitement</p>
                    <p className="text-sm text-yellow-700 mt-1">
                      Cette page se rafraîchit automatiquement. Ne la fermez pas.
                    </p>
                  </div>
                </div>
              )}

              {isPaid && (
                <div className="bg-green-50 border-l-4 border-green-400 p-4 mt-6">
                  <p className="font-semibold text-green-800">✅ Billet confirmé et envoyé par email</p>
                  <p className="text-sm text-green-700 mt-1">
                    Vérifiez votre boîte email ({ticketData.email}) et vos spams.
                  </p>
                </div>
              )}

              {isFailed && (
                <div className="bg-red-50 border-l-4 border-red-400 p-4 mt-6">
                  <p className="font-semibold text-red-800">❌ Le paiement a échoué</p>
                  <p className="text-sm text-red-700 mt-1">
                    Veuillez réessayer ou contacter le support si le problème persiste.
                  </p>
                </div>
              )}
            </div>

            {/* Boutons d'action */}
            <div className="flex flex-col sm:flex-row gap-3 pt-6 border-t print:hidden">
              <button
                onClick={() => window.location.href = '/'}
                className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors inline-flex items-center justify-center font-semibold"
              >
                <HomeIcon className="w-5 h-5 mr-2" />
                Retour à l'accueil
              </button>
              
              {isPending && (
                <button
                  onClick={checkPaymentStatus}
                  className="flex-1 px-6 py-3 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300 transition-colors inline-flex items-center justify-center font-semibold"
                >
                  <RefreshCwIcon className="w-5 h-5 mr-2" />
                  Actualiser
                </button>
              )}

              {isFailed && (
                <button
                  onClick={() => window.location.href = '/rotary/register'}
                  className="flex-1 px-6 py-3 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors inline-flex items-center justify-center font-semibold"
                >
                  Réessayer
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Informations de contact */}
        <div className="bg-white rounded-xl shadow-lg p-6 text-center print:hidden">
          <p className="text-gray-600 mb-2">
            Une question ? Besoin d'aide ?
          </p>
          <p className="text-blue-600 font-semibold">
            📧 contact@rotary-pg.org | ☎️ +241 XX XX XX XX
          </p>
        </div>
      </div>

      {/* Styles pour l'impression */}
      <style>{`
        @media print {
          body {
            background: white !important;
          }
          .print\\:hidden {
            display: none !important;
          }
          .print\\:shadow-none {
            box-shadow: none !important;
          }
          .print\\:bg-white {
            background: white !important;
          }
        }
      `}</style>
    </div>
  );
}
