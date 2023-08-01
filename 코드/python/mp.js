const measurement_id = `G-TTRX6G562V`;
const api_secret = `jdrgpUJ6Q72oPZDgWL0r1g`;
import fetch from 'node-fetch'


fetch(`https://www.google-analytics.com/mp/collect?measurement_id=${measurement_id}&api_secret=${api_secret}`, {
  method: "POST",
  body: JSON.stringify({
    client_id: '1517382458.1690790007',
    non_personalized_ads:false,
    events: [{
      name: 'purchase',
      params:{
        
        items:[],
        affiliation:"smart_store",
        currency:"KRW",
        transaction_id:"T_12345",
        value:10000,
        }
    }]
  })
});

