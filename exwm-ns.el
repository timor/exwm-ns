;; * Notification Server for EXWM
;; Simple implementation of Notification interface D-Bus specification
;; for the Emacs Window Manager project

;;; Usage:
;; To start the notification server, call =(exwm-ns-init)=.  Likewise it can be
;; deactivated with =(exwm-ns-deinit)=

;;; Globals:

;; #+BEGIN_SRC emacs-lisp
(require 'dbus)
;; #+END_SRC
;; ** D-Bus-Specific

;; We need to keep track of the registered D-Bus Method to be able to
;; de-initialize them.
;; #+BEGIN_SRC emacs-lisp
(defvar exwm-ns-registered-methods)
;; #+END_SRC

;; Some D-Bus identifiers are used more than once.
;; #+BEGIN_SRC emacs-lisp
(defvar exwm-ns-dbus-service "org.freedesktop.Notifications")
(defvar exwm-ns-dbus-path "/org/freedesktop/Notifications")
(defvar exwm-ns-dbus-interface "org.freedesktop.Notifications")
(defvar exwm-ns-server-version "0.1")
;; #+END_SRC
;;; Implementation:
;; ** D-Bus registration

;; #+BEGIN_SRC emacs-lisp
(defmacro exwm-ns-register-method (method handler)
  `(dbus-register-method :session exwm-ns-dbus-service exwm-ns-dbus-path exwm-ns-dbus-interface ,method ,handler))

(defun exwm-ns-register-service ()
  (cl-case (dbus-register-service :session exwm-ns-dbus-service)
    ((:primary-owner :already-owner) (message "D-Bus service org.freedesktop.Notifications registered."))
    (t (message "Could not register D-Bus service org.freedesktop.Notifications."))))

(defun exwm-ns-register-methods ()
  "Register all D-Bus methods."
  (setq exwm-ns-registered-methods
	(list
	 (exwm-ns-register-method "GetCapabilities" (lambda () '("body")))
	 (exwm-ns-register-method "Notify" 'exwm-ns-handle-notify)
	 (exwm-ns-register-method "CloseNotification" (lambda (id)
							(dbus-send-signal :session exwm-ns-dbus-service exwm-ns-dbus-path exwm-ns-dbus-interface "NotificationClosed" id 3)))
	 (exwm-ns-register-method "GetServerInformation" 'exwm-ns-handle-get-server-information)
	 )))
;; #+END_SRC

;; ** D-Bus event handlers
;; Main notification handler.  Outputs minimal event information as emacs message.
;; #+BEGIN_SRC emacs-lisp
(defun exwm-ns-handle-notify (app-name replaces-id app-icon summary body actions hints expire-timeout)
  (display-message-or-buffer (format "(%s) %s %s" app-name summary body)))

(defun exwm-ns-handle-get-server-information ()
  (list "emacs exwm notification server"
	"timor"
	exwm-ns-server-version
	"1.2"))
;; #+END_SRC

;; ** Starting and stopping
;; #+BEGIN_SRC emacs-lisp
(defun exwm-ns-init ()
  (exwm-ns-register-service)
  (exwm-ns-register-methods))

(defun exwm-ns-deinit ()
  (dolist (method exwm-ns-registered-methods)
    (dbus-unregister-object method))
  (dbus-unregister-service :session exwm-ns-dbus-service))

(provide 'exwm-ns)
;; #+END_SRC
