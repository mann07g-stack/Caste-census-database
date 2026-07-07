"use client";
import { useState, useEffect } from "react";
import axios from "axios";
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer } from 'recharts';

export default function AdminDashboard() {
  const [view, setView] = useState("LOGIN"); // LOGIN | DASHBOARD
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [records, setRecords] = useState([]);
  const [loading, setLoading] = useState(false);
  const [aiStatus, setAiStatus] = useState("");

  // --- 1. LOGIN LOGIC ---
  const handleLogin = async () => {
    try {
      const res = await axios.post("http://localhost:9090/api/auth/login", { username, password });
      if (res.data === "ROLE_ADMIN") {
        setView("DASHBOARD");
        fetchData();
      } else {
        alert("Only Admins can access this dashboard.");
      }
    } catch (e) {
      alert("Login Failed. Check credentials or Java Server.");
    }
  };

  // --- 2. FETCH DATA ---
  const fetchData = async () => {
    try {
      const res = await axios.get("http://localhost:9090/api/census/all");
      setRecords(res.data);
    } catch (e) {
      console.error("Error fetching data", e);
    }
  };

  // --- 3. RUN AI AGENT ---
  const runAi = async () => {
    setLoading(true);
    setAiStatus("Connecting to Python Brain...");
    try {
      const res = await axios.post("http://localhost:9090/api/census/run-ai");
      setAiStatus(res.data); // "AI Scan Completed..."
      fetchData(); // Refresh table to show new RED flags
    } catch (e) {
      setAiStatus("AI System Offline.");
    }
    setLoading(false);
  };
  // --- 4. MANUAL VERIFICATION (Green/Red Buttons) ---
  const updateStatus = async (id: string, action: "verify" | "flag") => {
    try {
      // Calls: /api/census/verify/{id} OR /api/census/flag/{id}
      await axios.post(`http://localhost:9090/api/admin/${action}/${id}`);
      fetchData(); // Refresh the table
    } catch (e) {
      alert(`Error: Could not ${action} record.`);
    }
  };

  // --- 5. SCHEME LOGIC (Client Side for Display) ---
  const getSchemes = (income: number, occupation: string) => {
    let schemes = [];
    if (income < 50000) schemes.push("🏠 PM Awas Yojana");
    if (income < 50000) schemes.push("🏥 Ayushman Bharat");
    if (income < 100000 && occupation.toLowerCase().includes("student")) schemes.push("🎓 Scholarship");
    return schemes.length > 0 ? schemes : ["No Schemes Eligible"];
  };

  // --- 6. PREPARE CHARTS ---
  const verifiedCount = records.filter((r:any) => r.verificationStatus === 'VERIFIED').length;
  const flaggedCount = records.filter((r:any) => r.verificationStatus === 'FLAGGED').length;
  const pendingCount = records.filter((r:any) => r.verificationStatus === 'PENDING').length;

  const pieData = [
    { name: 'Verified', value: verifiedCount, color: '#10B981' },
    { name: 'Flagged (AI)', value: flaggedCount, color: '#EF4444' },
    { name: 'Pending', value: pendingCount, color: '#3B82F6' },
  ];

  if (view === "LOGIN") {
    return (
      <div className="flex h-screen items-center justify-center bg-gray-900 text-white">
        <div className="p-8 bg-gray-800 rounded-lg shadow-xl w-96">
          <h1 className="text-3xl font-bold mb-6 text-center">🔐 Admin Portal</h1>
          <input className="w-full p-3 mb-4 rounded bg-gray-700 border border-gray-600" placeholder="Username" onChange={e => setUsername(e.target.value)} />
          <input className="w-full p-3 mb-6 rounded bg-gray-700 border border-gray-600" type="password" placeholder="Password" onChange={e => setPassword(e.target.value)} />
          <button onClick={handleLogin} className="w-full bg-blue-600 py-3 rounded font-bold hover:bg-blue-500 transition">LOGIN</button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      {/* HEADER */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-4xl font-extrabold text-gray-800">🇮🇳 Census Admin Dashboard</h1>
          <p className="text-gray-500">Real-time Data & AI Verification</p>
        </div>
        <div className="flex gap-4">
          <button onClick={runAi} disabled={loading} className={`px-6 py-3 rounded-lg font-bold text-white shadow-lg ${loading ? 'bg-gray-400' : 'bg-purple-600 hover:bg-purple-700'}`}>
            {loading ? "🤖 Scanning..." : "⚡ Run AI Verification"}
          </button>
          <button onClick={() => setView("LOGIN")} className="px-6 py-3 bg-red-500 text-white rounded-lg font-bold hover:bg-red-600">Logout</button>
        </div>
      </div>

      {/* STATUS BAR */}
      {aiStatus && <div className="bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4 mb-6 rounded shadow">{aiStatus}</div>}

      {/* CHARTS SECTION */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
        <div className="bg-white p-6 rounded-xl shadow-md">
          <h2 className="text-xl font-bold mb-4 text-gray-700">📊 Verification Status</h2>
          <ResponsiveContainer width="100%" height={250}>
            <PieChart>
              <Pie data={pieData} cx="50%" cy="50%" outerRadius={80} dataKey="value" label>
                {pieData.map((entry, index) => <Cell key={`cell-${index}`} fill={entry.color} />)}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>
        
        <div className="bg-white p-6 rounded-xl shadow-md">
           <h2 className="text-xl font-bold mb-4 text-gray-700">💰 Recent Incomes</h2>
           <ResponsiveContainer width="100%" height={250}>
            <BarChart data={records.slice(-5)}>
              <XAxis dataKey="householdId" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="income" fill="#8884d8" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* DATA TABLE */}
      <div className="bg-white rounded-xl shadow-lg overflow-hidden">
        <table className="min-w-full">
          <thead className="bg-gray-800 text-white">
            <tr>
              <th className="py-4 px-6 text-left">Photo</th>
              <th className="py-4 px-6 text-left">Household ID</th>
              <th className="py-4 px-6 text-left">Income</th>
              <th className="py-4 px-6 text-left">Status</th>
              <th className="py-4 px-6 text-left">Eligible Schemes</th>
              <th className="py-4 px-6 text-left text-sm font-semibold uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {records.map((r: any) => (
              <tr key={r.id} className="hover:bg-gray-50 transition">
                <td className="py-4 px-6">
                   {r.profileImageBase64 ? (
                     <img src={`data:image/png;base64,${r.profileImageBase64}`} className="h-12 w-12 rounded-full border-2 border-gray-300 object-cover" />
                   ) : <div className="h-12 w-12 bg-gray-200 rounded-full flex items-center justify-center">👤</div>}
                </td>
                <td className="py-4 px-6 font-medium text-gray-900">{r.householdId}</td>
                <td className="py-4 px-6">₹{r.income.toLocaleString()}</td>
                <td className="py-4 px-6">
                  <span className={`px-3 py-1 rounded-full text-xs font-bold ${
                    r.verificationStatus === 'FLAGGED' ? 'bg-red-100 text-red-800' : 
                    r.verificationStatus === 'VERIFIED' ? 'bg-green-100 text-green-800' : 'bg-blue-100 text-blue-800'
                  }`}>
                    {r.verificationStatus}
                  </span>
                </td>
                <td className="py-4 px-6 text-sm text-gray-600">
                  {getSchemes(r.income, r.occupation).map(s => (
                    <span key={s} className="inline-block bg-gray-100 px-2 py-1 rounded mr-2 mb-1 border border-gray-300">
                      {s}
                    </span>
                  ))}
                </td>
                <td className="py-4 px-6">
                  <div className="flex gap-2">
                    {r.verificationStatus !== 'VERIFIED' && (
                      <button 
                        onClick={() => updateStatus(r.id, 'verify')}
                        className="bg-green-500 hover:bg-green-600 text-white px-3 py-1.5 rounded shadow text-xs font-bold transition transform hover:scale-105"
                        title="Mark as Verified"
                      >
                        ✓ Verify
                      </button>
                    )}
                    
                    {r.verificationStatus !== 'FLAGGED' && (
                      <button 
                        onClick={() => updateStatus(r.id, 'flag')}
                        className="bg-red-500 hover:bg-red-600 text-white px-3 py-1.5 rounded shadow text-xs font-bold transition transform hover:scale-105"
                        title="Flag as Suspicious"
                      >
                        ✕ Flag
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            ))}
            {records.length === 0 && (
              <tr>
                <td colSpan={6} className="text-center py-8 text-gray-400 italic">
                  No records found. Sync some data from the App!
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
