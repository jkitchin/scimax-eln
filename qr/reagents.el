(require 'scimax-qr)

(org-link-set-parameters
 "reagent"
 :follow (lambda (path)
	   (org-id-goto path))
 :help-echo (lambda (win obj position)
	      (if (get-text-property position 'phs)
		  "    PHS!
Click to open, C-return to visit CommonChemistry."
		"Click to open, C-return to visit CommonChemistry."))
 :keymap (let ((map (copy-keymap org-mouse-map)))
                                   (define-key
				    map (kbd "C-<return>")
				    (lambda ()
				      (interactive)
				      (let* ((obj (org-element-context))
					     (path (org-element-property :path obj))
					     (cas (car
						   (org-ql-select "reagents.org"
						     `(and (property "ID" ,path)
							   (tags "reagent"))
						     :action '(org-entry-get nil "CAS")))))
					(if cas
					    (browse-url (format
							 "https://commonchemistry.cas.org/detail?cas_rn=%s"
							 cas))
					  (message "No CAS found.")))))
                                   map)
 :activate-func (lambda (start end path bracketp)
		  (when (member "phs"
				(car
				 (org-ql-select "reagents.org"
				   `(and (property "ID" ,path)
					 (tags "reagent"))
				   :action #'org-get-tags)))
		    (add-text-properties start end (list 'face '(:foreground "DarkOrange2")
							 'phs t)))))

(defun insert-reagent ()
  (interactive)
  (ivy-read "reagent: "
	    (org-ql-select "reagents.org"
	      '(and (property "ID") (tags "reagent"))
	      :action (lambda () (list
				  (org-get-heading t t t t)
				  :id (org-entry-get (point) "ID")
				  :tags (org-get-tags))))
	    :action '(1
		      ("o"
		       (lambda (cand)
			 (when (member "phs" (plist-get (cdr cand) :tags))
			   (ding)
			   (message "%s is particularly hazardous!" (car cand)))
			 (insert (format "[[reagent:%s][%s]]" (plist-get (cdr cand) :id) (car cand))))
		       "insert")
		      ("c" (lambda (cand)
			     (let ((cp (point))
				   (cb (current-buffer)))
			       (org-id-goto (plist-get (cdr cand) :id))
			       (when (org-entry-get nil "CAS")
				 (browse-url (format
					      "https://commonchemistry.cas.org/detail?cas_rn=%s"
					      (org-entry-get nil "CAS"))))
			       (switch-to-buffer cb)
			       (goto-char cp)))
		       "visit CAS"))))


(defun insert-from-qr ()
  (interactive)
  (let* ((id (with-temp-buffer
	       (insert (scimax-read-qr))
	       (org-mode)
	       (goto-char (point-min))
	       (plist-get (cadr (org-element-link-parser)) :path)))
	 ;; manual save-excursion
	 (cp (point))
	 (cb (current-buffer))
	 (result (progn
		   (org-id-goto id)
		   (when (member "phs" (org-get-tags))
		     (ding)
		     (message "%s is particularly hazardous!" (org-get-heading t t t t)))
		   (format "[[reagent:%s][%s]]"
			   id
			   (org-get-heading t t t t)))))
    (switch-to-buffer cb)
    (goto-char cp)
    (insert result)))



