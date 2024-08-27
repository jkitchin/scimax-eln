(require 'package)

(add-to-list 'package-archives (cons "melpa" "https://melpa.org/packages/") t)

(require 'use-package)
(use-package htmlize)

(require 'ox-publish)

(let* ((base-directory "./")
       (org-export-with-broken-links t)
       (org-publish-project-alist `(("html"
				     :base-directory ,base-directory
				     :base-extension "org"
				     :publishing-directory ,(concat base-directory "docs")
				     :exclude "docs"
				     :recursive t
				     :publishing-function org-html-publish-to-html
				     :auto-preamble t
				     :auto-sitemap t)
				    
				    ("static-html"
				     :base-directory ,base-directory
				     :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|dat\\|mov\\|txt\\|svg\\|aiff"
				     :publishing-directory ,(concat base-directory "docs")
				     :exclude "docs"
				     :recursive t
				     :publishing-function org-publish-attachment)

				    ;; ... all the components ...
				    ("scimax-eln" :components ("html" "static-html")))))

  (org-publish "scimax-eln" t))
