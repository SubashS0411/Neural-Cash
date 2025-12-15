import { useEffect } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { api } from './client/api.js';

const qc = new QueryClient();

function Placeholder({ title }) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-800 text-slate-100 flex items-center justify-center">
      <div className="max-w-xl w-full p-8 rounded-3xl bg-white/5 border border-white/10 shadow-2xl">
        <h1 className="text-2xl font-semibold mb-3">{title}</h1>
        <p className="text-sm text-slate-300">Wire this route to the backend endpoints under /api/v1.</p>
      </div>
    </div>
  );
}

function App() {
  useEffect(() => {
    api.setToken(localStorage.getItem('supabase_token'));
  }, []);

  return (
    <QueryClientProvider client={qc}>
      <BrowserRouter>
        <Routes>
          <Route path="/dashboard" element={<Placeholder title="Dashboard" />} />
          <Route path="/transactions" element={<Placeholder title="Transactions" />} />
          <Route path="/analytics" element={<Placeholder title="Analytics" />} />
          <Route path="/savings" element={<Placeholder title="Savings" />} />
          <Route path="/trips" element={<Placeholder title="Trips" />} />
          <Route path="/family" element={<Placeholder title="Family" />} />
          <Route path="/settings" element={<Placeholder title="Settings" />} />
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  );
}

export default App;
