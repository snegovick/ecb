;;; ecb-eshell.el --- eshell integration for the ECB.

;; $Id: ecb-eshell.el,v 1.10 2001/12/10 08:57:07 burtonator Exp $

;; Copyright (C) 2000-2003 Free Software Foundation, Inc.
;; Copyright (C) 2000-2003 Kevin A. Burton (burton@openprivacy.org)

;; Author: Kevin A. Burton (burton@openprivacy.org)
;; Maintainer: Kevin A. Burton (burton@openprivacy.org)
;; Location: http://relativity.yi.org
;; Keywords: 
;; Version: 1.0.0

;; This file is [not yet] part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free Software
;; Foundation; either version 2 of the License, or any later version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
;; FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
;; details.
;;
;; You should have received a copy of the GNU General Public License along with
;; this program; if not, write to the Free Software Foundation, Inc., 59 Temple
;; Place - Suite 330, Boston, MA 02111-1307, USA.

;;; Commentary:

;; Provides eshell integration for the ECB.  Basically allows you to jump to the
;; eshell in the compilation window, synch up the current eshell with the
;; current ECB buffer, etc.

;; If you enjoy this software, please consider a donation to the EFF
;; (http://www.eff.org)

;;; History:

;; - Sun Nov 18 2001 07:20 PM (burton@openprivacy.org): putting the cursor one
;;   line from the bottom of the window.

;;; TODO:

;; 

;; - should I use eshell-pre-command-hook to increase the size of the window if
;; we are in an ECB layout?? (and the ecb is activated)...

;; - only run eshell/cd if the current directory is different than the
;; eshell/pwd.
;;
;;   - we can't do this.  eshell/pwd does't return a string.  Instead we should
;;     change to the eshell-buffer and see what the directory is there...

;;; Code:

(defun ecb-eshell-current-buffer-sync()
  "Synchronize the eshell with the current buffer."
  (interactive)

  ;;only do this if the user is looking at the eshell buffer

  (if (ecb-eshell-running-p)      
      (let((new-directory default-directory))
    
        (set-buffer (get-buffer-create eshell-buffer-name))
        
        (end-of-buffer)
        
        ;;change the directory without showing the cd command
        (eshell/cd new-directory)
        
        ;;execute the command
        (eshell-send-input)

        (ecb-eshell-recenter)

        (set-window-point (get-buffer-window eshell-buffer-name) (point-max)))))

(defun ecb-eshell-recenter()
  "Recenter the eshell window so that the prompt is at the end of the buffer."

  (if (ecb-eshell-running-p)
  
      (let((window-start nil)
           (eshell-window nil))

        (setq eshell-window (get-buffer-window eshell-buffer-name))
        
        (save-excursion
          
          (set-buffer eshell-buffer-name)
          
          (end-of-buffer)
          
          (forward-line (* -1 (- (window-height eshell-window) 3)))
          
          (beginning-of-line)
          
          (setq window-start (point)))
        
        (set-window-start eshell-window window-start))))

(defun ecb-eshell-running-p()
  "Return true if eshell is currently running."

  (and (boundp 'eshell-buffer-name)
       eshell-buffer-name
       (get-buffer eshell-buffer-name)))
  
(defun ecb-eshell-goto-eshell()
  (interactive)
  
  ;;TODO: first... make sure that we change the compilation window to the eshell
  ;;buffer.

  (if (ecb-eshell-running-p)
      (progn 
        (select-window ecb-compile-window)

        (switch-to-buffer eshell-buffer-name))

    ;;we auto start the eshell here?  I think so..
    (select-window ecb-compile-window)
    
    (eshell))

  (ecb-eshell-recenter))

(defun ecb-eshell-resize()
  "Resize the eshell so more information is available.  This is usually done so
  that the eshell has more screen space after we execute a command. "
  (interactive)

  (if (and (ecb-eshell-running-p)
           ecb-minor-mode)

      (progn 
      
;;         (other-window 1)
        
;;         (pop-to-buffer "*eshell*" t)

;;         (other-window -1)

        )))

(add-hook 'ecb-current-buffer-sync-hook 'ecb-eshell-current-buffer-sync)

(add-hook 'ecb-redraw-layout-hooks 'ecb-eshell-recenter)

(add-hook 'eshell-pre-command-hook 'ecb-eshell-resize)

(define-key ecb-mode-map "\C-c.e" 'ecb-eshell-goto-eshell)

(provide 'ecb-eshell)

;;; ecb-eshell.el ends here