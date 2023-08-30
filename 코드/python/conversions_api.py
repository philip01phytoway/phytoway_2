
import time

from facebook_business.adobjects.serverside.action_source import ActionSource
from facebook_business.adobjects.serverside.content import Content
from facebook_business.adobjects.serverside.custom_data import CustomData
from facebook_business.adobjects.serverside.delivery_category import DeliveryCategory
from facebook_business.adobjects.serverside.event import Event
from facebook_business.adobjects.serverside.event_request import EventRequest
from facebook_business.adobjects.serverside.user_data import UserData
from facebook_business.api import FacebookAdsApi

access_token = 'EAATvHJZCvmGQBO3ZBDi7ccl8OthRy6AlJBcFdZCX6fDZBJxjH5ZBTDqZCBUZC3GOvxeaU8A40dxEkE3D61uKA9yfVNpjYoyu7TBW0bxzjZBSSR3wkgnBF0q91ZCvVxq4Ob2ev1ESjM5WJXJL5Cm5ufW9wxts7iXuy0x2RMbYBwCWVQcKWq1n9IZAAfixXvHa0esxhOIQZDZD'
pixel_id = '1481300945957522'

FacebookAdsApi.init(access_token=access_token)

user_data = UserData(
    emails=['philip@phytoway.com'],
    phones=['654982365', '23165498561'],
    # It is recommended to send Client IP and User Agent for Conversions API Events.
    # client_ip_address=request.META.get('REMOTE_ADDR'),
    # client_user_agent=request.headers['User-Agent'],
    fbc='fb.1.1554763741205.AbCdEfGhIjKlMnOpQrStUvWxYz1234567890',
    fbp='fb.1.1692668947595.877322391',
)

content = Content(
    product_id='fb.1.1692668947595.877322391',
    quantity=1,
    delivery_category=DeliveryCategory.HOME_DELIVERY,
)

custom_data = CustomData(
    contents=[content],
    currency='usd',
    value=123.45,
)

event = Event(
    event_name='Purchase',
    event_time=int(time.time()),
    user_data=user_data,
    custom_data=custom_data,
    event_source_url='http://jaspers-market.com/product/123',
    action_source=ActionSource.WEBSITE,
)

events = [event]

event_request = EventRequest(
    events=events,
    pixel_id=pixel_id,
    test_event_code='TEST36146',
)

event_response = event_request.execute()
print(event_request)
print(event_response)
