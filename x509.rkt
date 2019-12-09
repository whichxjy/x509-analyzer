#lang racket

(require "oid.rkt")

;; types
(define BOOLEAN #x01)           ;; boolean
(define INTEGER #x02)           ;; integer
(define BIT-STRING #x03)        ;; bit string
(define OCTET-STRING #x04)      ;; octet string
(define NULL #x05)              ;; null
(define OBJECT-IDENTIFIER #x06) ;; object identifier
(define UTF8-STRING #x0C)       ;; utf-8 string
(define PRINTABLE-STRING #x13)  ;; printable string
(define UTC-TIME #x17)          ;; utc time
(define SEQUENCE #x30)          ;; sequence
(define SET #x31)               ;; set

;; decode
(define (decode-X.509 cer-filename)
  ;; byte to hex string, e.g., #x55 -> "55"
  (define (byte->hex-str b)
    (~a (format "~X" b)
        #:width 2
        #:align 'right
        #:left-pad-string "0"))

  ;; read type-length-value
  ;; return (the length of tlv, value)
  (define (read-tlv in)
    ;; value type
    (define type (read-byte in))
    ;; init length of value
    (define len0 (read-byte in))
    ;; real length of value
    (define len len0)
    ;; length of tlv
    (define tlv-len 2)
    ;; get the real length of value
    (when (> len0 #x80)
      (set! len
            (for/fold ([len 0])
                      ([i (in-range (- len0 #x80))])
              (begin (set! tlv-len (add1 tlv-len))
                     (+ (* len 256) (read-byte in))))))
    ;; set the length of tlv
    (set! tlv-len (+ tlv-len len))
    
    ;; check type
    (cond
      ;; [boolean]
      [(= type BOOLEAN)
       (let ([val (if (= (read-byte in) #xFF)
                      "True" "False")])
         ;; return result
         (values tlv-len val))]
      ;; [integer]
      [(= type INTEGER)
       (let ([val (for/fold ([hex-str ""])
                            ([i (in-range len)])
                    (string-append hex-str
                                   (byte->hex-str (read-byte in))))])
         ;; return result
         (values tlv-len val))]
      ;; [bit string]
      [(= type BIT-STRING)
       (let* ([padding-len (read-byte in)]
              [bin-int (for/fold ([int 0])
                                 ([i (in-range (sub1 len))])
                         (+ (* int 256) (read-byte in)))]
              [val (arithmetic-shift bin-int (- padding-len))])
         ;; return result
         (values tlv-len val))]
      ;; [octet string]
      [(= type OCTET-STRING)
       (let ([val (for/fold ([hex-str ""])
                            ([i (in-range len)])
                    (string-append hex-str
                                   (byte->hex-str (read-byte in))))])
         ;; return result
         (values tlv-len val))]
      ;; [null]
      [(= type NULL)
       ;; return result
       (values tlv-len "NULL")]
      ;; [object identifier]
      [(= type OBJECT-IDENTIFIER)
       (let ([val ""])
         ;; special byte
         (let-values ([(spec1 spec2) (quotient/remainder (read-byte in) 40)])
           (set! val (string-append val
                                    (~a spec1) "." (~a spec2))))
         ;; the rest
         (let ([term 0])
           (for ([i (in-range (sub1 len))])
             (let* ([int-8 (read-byte in)]
                    [int-7 (bitwise-and int-8 #x7f)])
               ;; update term
               (set! term (+ (* term 128) int-7))
               ;; check if current byte has 0 as the most significant bit
               (when (= (bitwise-and int-8 #x80) 0)
                 ;; append current term to current value
                 (set! val (string-append val "." (~a term)))
                 ;; reset term
                 (set! term 0)))))
         ;; return result
         (values tlv-len (hash-ref oid-map val)))]
      ;; [printable string]
      [(or (= type UTF8-STRING)
           (= type PRINTABLE-STRING))
       (let ([val (read-string len in)])
         ;; return result
         (values tlv-len val))]
      ;; [utc time]
      [(= type UTC-TIME)
       (let ([val (read-string len in)])
         (define (str->utc-time str)
           (string-append
            ;; YY
            "20" (substring str 0 2) "-"
            ;; MM
            (substring str 2 4) "-"
            ;; DD
            (substring str 4 6) " "
            ;; hh
            (substring str 6 8) ":"
            ;; mm
            (substring str 8 10) ":"
            ;; ss
            (substring str 10 12)))
         ;; return result
         (values tlv-len (str->utc-time val)))]
      ;; [sequence] or [set] or [tag]
      [(or (= type SEQUENCE)
           (= type SET)
           (>= type #xa0))
       (let ([val-list '()])
         (let loop ([len-to-read len])
           (when (> len-to-read 0)
             (let-values ([(tlv-len val) (read-tlv in)])
               (set! val-list (append val-list (list val)))
               (loop (- len-to-read tlv-len)))))
         ;; return result
         (values tlv-len val-list))]
      ;; [error]
      [else
       (error "No Such Type")]))

  ;; display indentation
  (define (indent num)
    (display (make-string num #\space)))
  ;; number of spaces
  (define 1-TAB 4)
  (define 2-TAB 8)
  (define 3-TAB 12)

  ;; display X.509 certificate
  (define (display-X.509 cer-struct)
    (displayln "Certificate:")
    ;; ================== [Part 1] to be signed certificate ==================
    (let ([tbs-certificate (first cer-struct)])
      (indent 1-TAB)
      (displayln "Data:")
      ;; Version
      (let* [(version-str (first (first tbs-certificate)))
             (version (cond
                        [(string=? version-str "00") 1]
                        [(string=? version-str "01") 2]
                        [(string=? version-str "02") 3]
                        [else (error "Not Such Version")]))]
        (indent 2-TAB)
        (displayln (format "Version: ~a" version)))
      ;; Serial Number
      (let [(serial-number (second tbs-certificate))]
        (indent 2-TAB)
        (displayln (format "Serial Number: ~a" serial-number)))
      ;; Signature Algorithm Identifier
      (let [(signature-algorithm (first (third tbs-certificate)))]
        (indent 2-TAB)
        (displayln (format "Signature Algorithm: ~a" signature-algorithm)))
      ;; Issuer
      (let [(name-list (fourth tbs-certificate))]
        (indent 2-TAB)
        (displayln "Issuer")
        (for ([item name-list])
          (let ([kv (first item)])
            (indent 3-TAB)
            (displayln (format "~a: ~a" (first kv) (second kv))))))
      ;; Validity Period
      (let* ([validity-period (fifth tbs-certificate)]
             [not-before (first validity-period)]
             [not-after (second validity-period)])
        (indent 2-TAB)
        (displayln "Validity Period")
        (indent 3-TAB)
        (displayln (format "Not Before: ~a" not-before))
        (indent 3-TAB)
        (displayln (format "Not After: ~a" not-after)))
      ;; Subject
      (let [(name-list (sixth tbs-certificate))]
        (indent 2-TAB)
        (displayln "Subject")
        (for ([item name-list])
          (let ([kv (first item)])
            (indent 3-TAB)
            (displayln (format "~a: ~a" (first kv) (second kv))))))
      ;; Subject Public Key Information
      (let* ([info (seventh tbs-certificate)]
             [algorithm (first (first info))])
        (indent 2-TAB)
        (displayln "Subject Public Key Information")
        (indent 3-TAB)
        (displayln (format "Public Key Algorithm: ~a" algorithm))))
    ;; ===================== [Part 2] type of signature ======================
    (let* ([signature-type (second cer-struct)]
           [algorithm (first signature-type)])
      (indent 1-TAB)
      (displayln (format "Signature Algorithm: ~a" algorithm)))
    ;; ========================= [Part 3] signature ==========================
    (let ([signature (third cer-struct)])
      (indent 1-TAB)
      (displayln (format "Signature: ~X" signature))))
  
  ;; deal with the input file
  (call-with-input-file cer-filename #:mode 'binary
    (lambda (in)
      (let-values ([(_ cer-struct) (read-tlv in)])
        (display-X.509 cer-struct)))))

;; main function
(define (main)
  ;; get filename
  (define file-to-open
    (command-line
     #:program "X.509 Certificate Analyzer"
     #:args (filename)
     filename))
  ;; decode
  (decode-X.509 file-to-open))

(main)