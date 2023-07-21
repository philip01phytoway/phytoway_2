from slack_sdk import WebClient
from slack_sdk.errors import SlackApiError

slack_token = 'xoxb-624162262624-5602986501942-ZdpY7AElIjNdxZIfwxsrnjbD'

client = WebClient(token=slack_token)

# try:
#     response = client.chat_postMessage(channel='미리내_필립-플젝',
#                                        text='Test message from python slack api')
# except SlackApiError as e:
#     print('Error: {}'.format(e.response['error']))

response = client.conversations_history(channel='C05JG2JHLQZ')

print(response)