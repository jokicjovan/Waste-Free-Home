import zeroconf
import socket

from app.core.config import settings


class MDNSService:
    def __init__(self):
        self.zeroconf = zeroconf.Zeroconf()
        self.http_hub_service_info = None
        self.mqtt_broker_service_info = None
        self._setup_mdns()

    def _setup_mdns(self):
        desc = {'paths': ['/API/health', '/API/update-credentials']}
        self.http_hub_service_info = zeroconf.ServiceInfo(
            type_="_http._tcp.local.",
            name="WasteFreeHomeHTTPHub._http._tcp.local.",
            addresses=[socket.inet_aton(settings.hub_hostname)],
            port=settings.http_port,
            properties=desc,
            server="waste-free-home-http-hub.local."
        )
        self.mqtt_broker_service_info = zeroconf.ServiceInfo(
            type_="_mqtt._tcp.local.",
            name="WasteFreeHomeMQTTBroker._mqtt._tcp.local.",
            addresses=[socket.inet_aton(settings.hub_hostname)],
            port=settings.mqtt_broker_port,
            properties=desc,
            server="waste-free-home-mqtt-broker.local."
        )
        self.zeroconf.register_service(self.http_hub_service_info, ttl=3600)
        print("mDNS HTTP Hub Service Registered")
        self.zeroconf.register_service(self.mqtt_broker_service_info, ttl=3600)
        print("mDNS Mqtt Broker Service Registered")

    def close(self):
        if self.zeroconf:
            self.zeroconf.unregister_service(self.http_hub_service_info)
            print("mDNS Hub Service Unregistered")
            self.zeroconf.unregister_service(self.mqtt_broker_service_info)
            print("mDNS Mqtt Broker Service Unregistered")
            self.zeroconf.close()
