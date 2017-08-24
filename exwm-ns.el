(defvar exwm-ns-registered-methods)

(defvar exwm-ns-dbus-service "org.freedesktop.Notifications")
(defvar exwm-ns-dbus-path "/org/freedesktop/Notifications")
(defvar exwm-ns-dbus-interface "org.freedesktop.Notifications")
(defvar exwm-ns-server-version "0.1")

(defmacro exwm-ns-register-method (method handler)
  `(dbus-register-method :session exwm-ns-dbus-service exwm-ns-dbus-path exwm-ns-dbus-interface ,method ,handler))

(defun exwm-ns-register-service ()
  (case (dbus-register-service :session exwm-ns-dbus-service)
    ((:primary-owner :already-owner) (message "D-Bus service org.freedesktop.Notifications registered."))
    (t (message "Could not register D-Bus service org.freedesktop.Notifications."))))

(defun exwm-ns-handle-notify (app-name replaces-id app-icon summary body actions hints expire-timeout)
  (message "(%s) %s %s" app-name summary body)
  ;(message "hints: %s\nactions: %s\n expire-timeout: %s" hints actions expire-timeout)
  )

(defun exwm-ns-handle-get-server-information ()
  (list "emacs exwm notification server"
	"timor"
	exwm-ns-server-version
	"1.2"))

(defun exwm-ns-register-methods ()
  (setq exwm-ns-registered-methods
	(list 
	 (exwm-ns-register-method "GetCapabilities" (lambda () '("body")))
	 (exwm-ns-register-method "Notify" 'exwm-ns-handle-notify)
	 (exwm-ns-register-method "CloseNotification" (lambda (id)
							(dbus-send-signal :session exwm-ns-dbus-service exwm-ns-dbus-path exwm-ns-dbus-inferface "NotificationClosed" id 3)))
	 (exwm-ns-register-method "GetServerInformation" 'exwm-ns-handle-get-server-information)
	 )))

(defun exwm-ns-init ()
  (exwm-ns-register-service)
  (exwm-ns-register-methods))

(defun exwm-ns-deinit ()
  (dolist (method exwm-ns-registered-methods)
    (dbus-unregister-object method))
  (dbus-unregister-service :session exwm-ns-dbus-service))

(provide 'exwm-ns)
