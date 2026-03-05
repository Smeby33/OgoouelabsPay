import React, { useState, useEffect } from 'react';
import { 
  LayoutDashboardIcon, 
  TicketIcon, 
  CalendarIcon, 
  CreditCardIcon,
  MailIcon,
  LogOutIcon,
  UsersIcon,
  TrendingUpIcon,
  SearchIcon,
  DownloadIcon
} from 'lucide-react';
import axios from 'axios';

const API_URL ='http://localhost:5000';

export function AdminDashboard() {
  const [currentView, setCurrentView] = useState<'dashboard' | 'events' | 'tickets' | 'transactions' | 'emails'>('dashboard');
  const [dashboardData, setDashboardData] = useState<any>(null);
  const [events, setEvents] = useState<any[]>([]);
  const [tickets, setTickets] = useState<any[]>([]);
  const [transactions, setTransactions] = useState<any[]>([]);
  const [emails, setEmails] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [adminUser, setAdminUser] = useState<any>(null);

  useEffect(() => {
    // Vérifier l'authentification
    const token = localStorage.getItem('admin_token');
    const user = localStorage.getItem('admin_user');
    
    if (!token || !user) {
      window.location.href = '/admin/login';
      return;
    }
    
    setAdminUser(JSON.parse(user));
    loadData();
  }, [currentView]);

  const loadData = async () => {
    setIsLoading(true);
    const token = localStorage.getItem('admin_token');
    const headers = { Authorization: `Bearer ${token}` };

    try {
      switch (currentView) {
        case 'dashboard':
          const dashRes = await axios.get(`${API_URL}/admin/dashboard`, { headers });
          setDashboardData(dashRes.data);
          break;
        case 'events':
          const eventsRes = await axios.get(`${API_URL}/admin/events`, { headers });
          setEvents(eventsRes.data.events);
          break;
        case 'tickets':
          const ticketsRes = await axios.get(`${API_URL}/admin/tickets`, { headers });
          setTickets(ticketsRes.data.tickets);
          break;
        case 'transactions':
          const transRes = await axios.get(`${API_URL}/admin/transactions`, { headers });
          setTransactions(transRes.data.transactions);
          break;
        case 'emails':
          const emailsRes = await axios.get(`${API_URL}/admin/emails`, { headers });
          setEmails(emailsRes.data.emails);
          break;
      }
    } catch (err: any) {
      console.error('Erreur chargement:', err);
      if (err.response?.status === 401 || err.response?.status === 403) {
        handleLogout();
      }
    } finally {
      setIsLoading(false);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    window.location.href = '/admin/login';
  };

  const handleResendEmail = async (reference: string) => {
    if (!confirm(`Êtes-vous sûr de vouloir renvoyer l'email de confirmation pour le billet ${reference} ?`)) {
      return;
    }

    const token = localStorage.getItem('admin_token');
    const headers = { Authorization: `Bearer ${token}` };

    try {
      setIsLoading(true);
      const response = await axios.post(
        `${API_URL}/rotary/tickets/${reference}/resend-email`,
        {},
        { headers }
      );

      if (response.data.success) {
        alert(`✅ Email envoyé avec succès à ${response.data.recipient}`);
        loadData(); // Recharger les données
      }
    } catch (err: any) {
      console.error('Erreur:', err);
      alert(`❌ Erreur lors de l'envoi: ${err.response?.data?.error || err.message}`);
    } finally {
      setIsLoading(false);
    }
  };

  const renderDashboard = () => (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Vue d'ensemble</h2>
      
      {/* Statistiques */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div className="bg-blue-50 rounded-xl p-6 border-l-4 border-blue-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-blue-600 font-semibold">Événements</p>
              <p className="text-3xl font-bold text-blue-900 mt-2">
                {dashboardData?.stats.total_evenements}
              </p>
            </div>
            <CalendarIcon className="w-12 h-12 text-blue-500 opacity-20" />
          </div>
        </div>

        <div className="bg-green-50 rounded-xl p-6 border-l-4 border-green-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-green-600 font-semibold">Billets vendus</p>
              <p className="text-3xl font-bold text-green-900 mt-2">
                {dashboardData?.stats.total_billets_vendus}
              </p>
            </div>
            <TicketIcon className="w-12 h-12 text-green-500 opacity-20" />
          </div>
        </div>

        <div className="bg-purple-50 rounded-xl p-6 border-l-4 border-purple-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-purple-600 font-semibold">Revenus totaux</p>
              <p className="text-3xl font-bold text-purple-900 mt-2">
                {(dashboardData?.stats.revenus_totaux || 0).toLocaleString()} F
              </p>
            </div>
            <TrendingUpIcon className="w-12 h-12 text-purple-500 opacity-20" />
          </div>
        </div>

        <div className="bg-orange-50 rounded-xl p-6 border-l-4 border-orange-500">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-orange-600 font-semibold">En attente</p>
              <p className="text-3xl font-bold text-orange-900 mt-2">
                {dashboardData?.stats.transactions_en_attente}
              </p>
            </div>
            <CreditCardIcon className="w-12 h-12 text-orange-500 opacity-20" />
          </div>
        </div>
      </div>

      {/* Derniers billets vendus */}
      <div className="bg-white rounded-xl shadow-lg p-6">
        <h3 className="text-xl font-bold text-gray-900 mb-4">Derniers billets vendus</h3>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead>
              <tr>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Référence</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Client</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Événement</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Catégorie</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Montant</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {dashboardData?.recent_tickets.map((ticket: any) => (
                <tr key={ticket.reference_billet} className="hover:bg-gray-50">
                  <td className="px-4 py-3 text-sm font-mono text-blue-600">{ticket.reference_billet}</td>
                  <td className="px-4 py-3 text-sm">{ticket.prenom} {ticket.nom}</td>
                  <td className="px-4 py-3 text-sm">{ticket.evenement_titre}</td>
                  <td className="px-4 py-3 text-sm">{ticket.nom_categorie}</td>
                  <td className="px-4 py-3 text-sm font-semibold">{ticket.montant_total.toLocaleString()} F</td>
                  <td className="px-4 py-3 text-sm text-gray-500">
                    {new Date(ticket.created_at).toLocaleDateString('fr-FR')}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );

  const renderEvents = () => (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Événements</h2>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {events.map((event) => (
          <div key={event.id} className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex justify-between items-start mb-4">
              <h3 className="text-lg font-bold text-gray-900">{event.titre}</h3>
              <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                event.statut === 'publie' ? 'bg-green-100 text-green-800' :
                event.statut === 'termine' ? 'bg-gray-100 text-gray-800' :
                'bg-yellow-100 text-yellow-800'
              }`}>
                {event.statut}
              </span>
            </div>
            <p className="text-sm text-gray-600 mb-4">{event.description}</p>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p className="text-gray-500">Date</p>
                <p className="font-semibold">{new Date(event.date_evenement).toLocaleDateString('fr-FR')}</p>
              </div>
              <div>
                <p className="text-gray-500">Lieu</p>
                <p className="font-semibold">{event.lieu}</p>
              </div>
              <div>
                <p className="text-gray-500">Billets vendus</p>
                <p className="font-semibold text-green-600">{event.billets_vendus}</p>
              </div>
              <div>
                <p className="text-gray-500">Revenus</p>
                <p className="font-semibold text-purple-600">{(event.revenus || 0).toLocaleString()} F</p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  const renderTickets = () => (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Billets</h2>
        <div className="relative">
          <SearchIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
          <input
            type="text"
            placeholder="Rechercher un billet..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </div>
      
      <div className="bg-white rounded-xl shadow-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Référence</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Client</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Email</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Événement</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Statut</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Montant</th>
                <th className="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {tickets
                .filter(t => 
                  t.reference_billet.toLowerCase().includes(searchQuery.toLowerCase()) ||
                  t.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
                  `${t.prenom} ${t.nom}`.toLowerCase().includes(searchQuery.toLowerCase())
                )
                .map((ticket) => (
                <tr key={ticket.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3 text-sm font-mono text-blue-600">{ticket.reference_billet}</td>
                  <td className="px-4 py-3 text-sm">{ticket.prenom} {ticket.nom}</td>
                  <td className="px-4 py-3 text-sm text-gray-600">{ticket.email}</td>
                  <td className="px-4 py-3 text-sm">{ticket.evenement_titre}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-1 rounded-full text-xs font-semibold ${
                      ticket.statut_paiement === 'paye' ? 'bg-green-100 text-green-800' :
                      ticket.statut_paiement === 'en_attente' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-red-100 text-red-800'
                    }`}>
                      {ticket.statut_paiement}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-sm font-semibold">{ticket.montant_total.toLocaleString()} F</td>
                  <td className="px-4 py-3">
                    {ticket.statut_paiement === 'paye' && (
                      <button
                        onClick={() => handleResendEmail(ticket.reference_billet)}
                        className="flex items-center space-x-1 px-3 py-1 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-xs"
                        title="Renvoyer l'email de confirmation"
                      >
                        <MailIcon className="w-4 h-4" />
                        <span>Renvoyer email</span>
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-100">
      {/* Header */}
      <div className="bg-white shadow-md">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-4">
              <LayoutDashboardIcon className="w-8 h-8 text-blue-600" />
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Administration Rotary</h1>
                <p className="text-sm text-gray-500">
                  Bienvenue, {adminUser?.prenom} {adminUser?.nom}
                </p>
              </div>
            </div>
            <button
              onClick={handleLogout}
              className="flex items-center space-x-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
              <LogOutIcon className="w-5 h-5" />
              <span>Déconnexion</span>
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex gap-6">
          {/* Sidebar */}
          <div className="w-64 bg-white rounded-xl shadow-lg p-4">
            <nav className="space-y-2">
              <button
                onClick={() => setCurrentView('dashboard')}
                className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${
                  currentView === 'dashboard'
                    ? 'bg-blue-100 text-blue-700'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
              >
                <LayoutDashboardIcon className="w-5 h-5" />
                <span className="font-semibold">Dashboard</span>
              </button>
              
              <button
                onClick={() => setCurrentView('events')}
                className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${
                  currentView === 'events'
                    ? 'bg-blue-100 text-blue-700'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
              >
                <CalendarIcon className="w-5 h-5" />
                <span className="font-semibold">Événements</span>
              </button>
              
              <button
                onClick={() => setCurrentView('tickets')}
                className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${
                  currentView === 'tickets'
                    ? 'bg-blue-100 text-blue-700'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
              >
                <TicketIcon className="w-5 h-5" />
                <span className="font-semibold">Billets</span>
              </button>
              
              <button
                onClick={() => setCurrentView('transactions')}
                className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${
                  currentView === 'transactions'
                    ? 'bg-blue-100 text-blue-700'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
              >
                <CreditCardIcon className="w-5 h-5" />
                <span className="font-semibold">Transactions</span>
              </button>
              
              <button
                onClick={() => setCurrentView('emails')}
                className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${
                  currentView === 'emails'
                    ? 'bg-blue-100 text-blue-700'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
              >
                <MailIcon className="w-5 h-5" />
                <span className="font-semibold">Emails</span>
              </button>
            </nav>
          </div>

          {/* Content */}
          <div className="flex-1">
            {isLoading ? (
              <div className="flex justify-center items-center h-64">
                <div className="w-12 h-12 border-4 border-blue-600 border-t-transparent rounded-full animate-spin"></div>
              </div>
            ) : (
              <>
                {currentView === 'dashboard' && dashboardData && renderDashboard()}
                {currentView === 'events' && renderEvents()}
                {currentView === 'tickets' && renderTickets()}
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
