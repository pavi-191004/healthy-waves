
import LoginSignup from './components/loginsignup/LoginSignup';
import EntryPage from './components/EntryPage/EntryPage';
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
function App() {
  return (
    <Router>
    <Routes>
      <Route path="/" element={<EntryPage />} />
      <Route path="/signup" element={<LoginSignup />} />
    </Routes>
  </Router>
  )
}

export default App;
