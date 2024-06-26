;;; scimax-ob-arduino.el --- Scimax interface to arduino-cli with org-babel

;;; Commentary:
;;

(require 'org)
(require 'ob)
(use-package arduino-mode)
(use-package arduino-cli-mode)

(defgroup ob-arduino nil
  "org-mode blocks for Arduino."
  :group 'org)

(defcustom ob-arduino:program "arduino-cli"
  "Default Arduino program name."
  :group 'ob-arduino
  :type 'string)

(defcustom ob-arduino:port "/dev/ttyACM0"
  "Default Arduino port."
  :group 'ob-arduino
  :type 'string)

(defcustom ob-arduino:board "arduino:avr:uno"
  "Default Arduino board."
  :group 'ob-arduino
  :type 'string)


;;;###autoload
(defun org-babel-execute:arduino (body params)
  "org-babel arduino hook."
  (let* ((port (or (cdr (assoc :port params)) ob-arduino:port))
         (board (or (cdr (assoc :board params)) ob-arduino:board))
	 (verify(cdr (assoc :verify params)) )
         (code (org-babel-expand-body:generic body params))
	 (src-dir (make-temp-file "ob-arduino-" t))
         (src-file (f-join src-dir (concat (file-name-nondirectory src-dir) ".ino"))))

    (with-temp-file src-file
      (insert code))

    ;; Compile step
    (org-babel-eval
     (s-format "arduino-cli compile --fqbn ${board} ${src-dir}"
	       'aget (list (cons "board" board)
			   (cons "src-dir" src-dir)))
     "")
    (org-babel-eval
     (s-format "arduino-cli upload -p ${port} --fqbn ${board} ${src-dir}"
	       'aget (list (cons "board" board)
			   (cons "port" port)
			   (cons "src-dir" src-dir)))
     "")))


;;;###autoload
(eval-after-load 'org
  '(add-to-list 'org-src-lang-modes '("arduino" . arduino)))




(provide 'scimax-ob-arduino)

;;; scimax-ob-arduino.el ends here
