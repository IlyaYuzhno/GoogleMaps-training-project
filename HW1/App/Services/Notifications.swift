//
//  Notifications.swift
//  HW1
//
//  Created by Ilya Doroshkevitch on 18.04.2021.
//

import Foundation
import UserNotifications

class Notifications {

    func registerNotification() {
        self.sendNotificatioRequest(
            content: self.makeNotificationContent(),
            trigger: self.makeIntervalNotificatioTrigger()
        )
    }

    func makeNotificationContent() -> UNNotificationContent {
        // Внешний вид уведомления
        let content = UNMutableNotificationContent()
        // Заголовок
        content.title = "Апп скучает"
        // Подзаголовок
        content.subtitle = "Пожалуйста, вернитесь обратно"
        // Основное сообщение
        content.body = "Пора отслеживать треки!!!"
        // Цифра в бейдже на иконке
        content.badge = 4
        return content
    }

    func makeIntervalNotificatioTrigger() -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(
            // Количество секунд до показа уведомления - 30 minutes
            timeInterval: 1800,
            // Надо ли повторять
            repeats: false
        )
    }

    func sendNotificatioRequest(
        content: UNNotificationContent,
        trigger: UNNotificationTrigger) {

        // Создаём запрос на показ уведомления
        let request = UNNotificationRequest(
            identifier: "alarm",
            content: content,
            trigger: trigger
        )

        let center = UNUserNotificationCenter.current()
        // Добавляем запрос в центр уведомлений
        center.add(request) { error in
            // Если не получилось добавить запрос,
            // показываем ошибку, которая при этом возникла
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
