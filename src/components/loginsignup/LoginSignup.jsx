import React,{ useState} from 'react';

function LoginSignup() {
  const [action,setAction] =useState("Sign Up")
  return (
    <div className="container">
      <div className="header">
        <div className="text">{action}</div>
        <div className="underline"></div>
      </div>

      <div className="inputs">
        {action==="Login"?<div></div>:<div className="input">
         <img src="./imgs/person.png" alt="img"></img>
          <input type="text" placeholder="Full Name" />
        </div>}
        
        <div className="input">
        <img src="./imgs/email.png" alt="img"></img>
          <input type="email" placeholder="Email"/>
        </div>

        <div className="input">
        <img src="./imgs/password.png" alt="img"></img>
          <input type="password" placeholder="Password" />
        </div>
      </div>
      {action==="Sign Up"?<div></div>:<div className="forget-password">lost password ?<span>click here</span></div>
      }
      <div className="submit-container">
      <div className={action === "Login" ? "submit gray" : "submit"} onClick={() => setAction("Sign Up")}>Sign Up</div>
      <div className={action === "Sign Up" ? "submit gray" : "submit"} onClick={() => setAction("Login")}>Login</div>

    </div>
    </div>
  );
}

export default LoginSignup;
