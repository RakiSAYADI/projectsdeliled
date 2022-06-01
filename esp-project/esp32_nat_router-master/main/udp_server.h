/*
 * udp_server.h
 *
 *  Created on: Oct 01, 2019
 *      Author: raki
 */

#ifndef MAIN_UDP_SERVER_H_
#define MAIN_UDP_SERVER_H_

#include "lwip/sockets.h"

#define ADDRESS_UDP "192.168.2.1"
#define PORT_UDP 201
#define UDP_MAX_SLAVES 5

void UDPServer();

typedef struct
{
	uint8_t id;
	bool enable;
	struct sockaddr_in6 source_addr_slave;
} SlaveUnit_Typedef;

#endif /* MAIN_UDP_SERVER_H_ */
