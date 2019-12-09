#lang racket

(provide oid-map)

;; http://www.oid-info.com
(define oid-map
  (make-hash
   (list
    (cons "1.2.840.113549.1.1.1" "RSA")
    (cons "1.2.840.113549.1.1.11" "SHA-256 with RSA")
    (cons "1.3.6.1.4.1.311.60.2.1.2" "jurisdictionOfIncorporationStateOrProvinceName")
    (cons "1.3.6.1.4.1.311.60.2.1.3" "jurisdictionOfIncorporationCountryName")
    (cons "1.3.6.1.4.1.11129.2.4.2" "ctEnabled")
    (cons "1.3.6.1.5.5.7.1.1" "authorityInfoAccess")
    (cons "2.5.4.3" "commonName")
    (cons "2.5.4.5" "serialNumber")
    (cons "2.5.4.6" "countryName")
    (cons "2.5.4.7" "localityName")
    (cons "2.5.4.8" "stateOrProvinceName")
    (cons "2.5.4.10" "organizationName")
    (cons "2.5.4.11" "organizationalUnitName")
    (cons "2.5.4.15" "businessCategory")
    (cons "2.5.29.14" "subjectKeyIdentifier")
    (cons "2.5.29.15" "keyUsage")
    (cons "2.5.29.17" "subjectAltName")
    (cons "2.5.29.19" "basicConstraints")
    (cons "2.5.29.31" "cRLDistributionPoints")
    (cons "2.5.29.32" "certificatePolicies")
    (cons "2.5.29.35" "authorityKeyIdentifier")
    (cons "2.5.29.37" "extKeyUsage"))))