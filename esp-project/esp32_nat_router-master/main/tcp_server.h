/*
 * tcp_server.h
 *
 *  Created on: Oct 01, 2019
 *      Author: raki
 */

#ifndef MAIN_TCP_SERVER_H_
#define MAIN_TCP_SERVER_H_

#define ADDRESS_TCP "192.168.2.1"
#define PORT_TCP 3333
#define KEEPALIVE_IDLE 5
#define KEEPALIVE_INTERVAL 5
#define KEEPALIVE_COUNT 3

void sendTCPCryptedMessage(const char *text);

void TCPServer(void);

extern bool UVTaskIsOn;
extern bool tcpDiconnect;
extern bool stopEventTrigerred;
extern bool detectionTriggered;

#endif /* MAIN_TCP_SERVER_H_ */
