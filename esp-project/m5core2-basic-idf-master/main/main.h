#ifndef MAIN_MAIN_H_
#define MAIN_MAIN_H_

#define delay(ms) (vTaskDelay(ms/portTICK_RATE_MS))
#define delete(task) (vTaskDelete(task))

#endif /* MAIN_MAIN_H_ */