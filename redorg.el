(require 'csv)

(setq redorg-redmine-url "http://10.65.10.4:3000/")
(setq redorg-query-id "6")
(setq redorg-project-names '("spine" "mediation-miaso"))
(setq redorg-autologin-cookie "LC0K44Lbq4O70bMu5eG8QJHccc0fCN7bp27rgjei")
(setq redorg-buffer-name "regorg.org")

;; relies on following variables
;;   redorg-redmine-url - base url of redmine 
;;   redorg-query-id - id of the query
;;   redorg-project-names - list of project names to import tasks from
;;   redorg-autologin-cookie - cookie to login into redmine
;;   redorg-buffer-name - name of buffer to insert tasks
(defun import-redmine-tasks () 
  "imports tasks from redmine"
  (interactive)
  (mapc 'process-project redorg-project-names))

(defun process-project (prj-name)
  "queries csv data on project PRJ-NAME from redmine"
  ()
  (with-temp-buffer
    (append-to-buffer redorg-buffer-name (list "\n" "** " prj-name "\n"))
    (call-process "curl"
                  nil
                  t
                  nil
                  "-s"
                  "--cookie" (concat "autologin=" redorg-autologin-cookie)
                  (concat redorg-redmine-url "projects/" prj-name "/issues?query_id=" redorg-query-id "&format=csv"))
    (mapc 'process-one-task (csv-parse-buffer t))
    (append-to-buffer redorg-buffer-name (list "\n\n"))))


(defun process-export-file (file-name)
  "processes csv file name FILE_NAME"
  ()
  (with-temp-buffer
    (append-to-buffer redorg-buffer-name (list "** " file-name "\n"))
    (insert-file-contents file-name)
    (mapc 'process-one-task (csv-parse-buffer t))
    (append-to-buffer redorg-buffer-name (list "\n\n"))))

;; uses current buffer ???
(defun process-one-task (task)
  "processes one task in csv form. TASK is a list of alists"
  ()
  (append-to-buffer redorg-buffer-name (list "*** TODO " (my-assoc "Subject" task) " (" (my-assoc "#" task) ") \n" )))

(defun my-assoc (key where) 
  "returns cdr from (assoc KEY WHERE)"
  () (cdr (assoc key where)))

(defun append-to-buffer (buffer texts)
  "appends each element from TEXTS to BUFFER"
  ()
  (let ((orig-buffer (current-buffer)))
    (save-excursion
      (let ((buff (get-buffer-create buffer)))
        (set-buffer buff)
        (mapc 'insert texts)))))


(defun append-to-buffer (buffer texts)
  ()
  (let ((old-buf (current-buffer)))
    (save-excursion
      (let ((new-buf (get-buffer-create buffer)))
        (set-buffer new-buf)
        (dolist (text texts)
          (insert-string text))))))

