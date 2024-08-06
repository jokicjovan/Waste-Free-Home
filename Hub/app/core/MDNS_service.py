import zeroconf
import socket

from app.core.config import settings


class MDNSService:
    def __init__(self):
        self.zeroconf = zeroconf.Zeroconf()
        self.service_info = None
        self._setup_mdns()

    def _setup_mdns(self):
        desc = {'paths': ['/API/health', '/API/update-credentials']}
        self.service_info = zeroconf.ServiceInfo(
            type_="_http._tcp.local.",
            name="WasteFreeHomeHub._http._tcp.local.",
            addresses=[socket.inet_aton(settings.hub_hostname)],
            port=settings.hub_port,
            properties=desc,
            server="waste-free-home-hub.local."
        )
        self.zeroconf.register_service(self.service_info, ttl=3600)
        print("mDNS Service Registered")

    def close(self):
        if self.zeroconf:
            self.zeroconf.unregister_service(self.service_info)
            self.zeroconf.close()
            print("mDNS Service Unregistered")
