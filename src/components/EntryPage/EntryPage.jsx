import React  from 'react';
import { useNavigate } from "react-router-dom";


    const EntryPage = () => {
        const navigate = useNavigate();
      
        const goToSignUp = () => {
          navigate("/signup");
        };
    return (
        
     <div className="Entry">
      <div className='quote'>Every bite you take is a step toward better health</div>
      <div><button className='submit' onClick={goToSignUp}>Sign Up</button></div>
     </div>
    );
};
export default EntryPage;