import requests

# # Your Bot User OAuth Token
# bot_token = "xoxb-624162262624-5602986501942-aEmkKlysFPB2mKOTeo3TAqIS"

# # API endpoint for posting messages
# url = "https://slack.com/api/chat.postMessage"

# # Slack Block Kit JSON for the Thank You Card
# thank_you_card = {
#     "blocks": [
#         {
#             "type": "section",
#             "text": {
#                 "type": "mrkdwn",
#                 "text": "🎉 Thank You! 🎉"
#             }
#         },
#         {
#             "type": "image",
#             "image_url": "https://example.com/thank_you_image.png",
#             "alt_text": "Thank You Image"
#         },
#         {
#             "type": "section",
#             "text": {
#                 "type": "mrkdwn",
#                 "text": "Thank you for being awesome! :tada:"
#             }
#         }
#     ]
# }

# # Parameters for the message
# payload = {
#     "channel": "#C05JG2JHLQZ",  # Replace with the channel or user ID you want to send the message to
#     "blocks": thank_you_card["blocks"],
#     "as_user": True
# }

# # Send the request
# response = requests.post(url, headers={"Authorization": f"Bearer {bot_token}"}, json=payload)

# # Check if the message was sent successfully
# if response.status_code == 200 and response.json()["ok"]:
#     print("Thank You Card sent successfully!")
# else:
#     print("Failed to send Thank You Card:", response.json())







from flask import Flask, request, jsonify

app = Flask(__name__)

# Your Bot User OAuth Token
bot_token = "xoxb-624162262624-5602986501942-aEmkKlysFPB2mKOTeo3TAqIS"

@app.route("/slack/interactions", methods=["POST"])
def handle_slack_interactions():
    payload = request.json
    # Parse the payload and handle the interaction from the modal
    # (e.g., check which button was clicked, process user input, etc.)

    # Respond to the interaction (e.g., show a confirmation message)
    response = {
        "response_action": "clear"  # Clear the modal after the interaction
    }
    return jsonify(response)

# The code to open the modal
def open_modal(trigger_id):
    url = "https://slack.com/api/views.open"
    headers = {
        "Authorization": f"Bearer {bot_token}",
        "Content-Type": "application/json"
    }
    payload = {
        "trigger_id": trigger_id,
        "view": {
            "type": "modal",
            "callback_id": "your_modal_callback_id",
            "title": {
                "type": "plain_text",
                "text": "Your Modal Title"
            },
            "blocks": [
                # Define the blocks and interactive elements of your modal here
            ],
            "submit": {
                "type": "plain_text",
                "text": "Submit"
            }
        }
    }
    response = requests.post(url, headers=headers, json=payload)
    return response

# Example endpoint to trigger the modal
@app.route("/slack/open_modal", methods=["POST"])
def trigger_modal():
    trigger_id = request.form.get("trigger_id")
    open_modal(trigger_id)
    return "", 200

if __name__ == "__main__":
    app.run(debug=True)
