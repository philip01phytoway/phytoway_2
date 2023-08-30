const measurement_id = `G-TTRX6G562V`;
const api_secret = `jdrgpUJ6Q72oPZDgWL0r1g`;
const gclid = "EAIaIQobChMIgKSP3Ny8gAMVjMSWCh0YxQXKEAEYASAAEgKtH_D_BwO"
import fetch from 'node-fetch'


// google_track_id  | GA1.1.378632692.1692668948
// google_session_id | GS1.1.1692668947.1.1.1692669120.0.0.0



fetch(`https://www.google-analytics.com/mp/collect?measurement_id=${measurement_id}&api_secret=${api_secret}`, {
  method: "POST",
  body: JSON.stringify({
    client_id: '159159515.1692668949',
    // gclid : "EAIaIQobChMIgKSP3Ny8gAMVjMSWCh0YxQXKEAEYASAAEgKtH_D_BwO",
    non_personalized_ads:false,
    events: [{
      name: 'click_ad',
      params:{
        
        items:[],
        id:1234,
        category:"content",
        lead_id:"gijklm",
        // value:30000,
        }
    }]
    
  })
});

