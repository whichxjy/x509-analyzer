# X.509 Certificate Analyzer

X.509 certificate analyzer in Racket.

## Usage

```
racket x509.rkt /path/to/certificate/file
```

## Example

```
racket x509.rkt /test/google.com.crt
```

```
Certificate:
    Data:
        Version: 3
        Serial Number: 01e3b49aa18d8aa981256950b8
        Signature Algorithm: SHA-256 with RSA
        Issuer
            organizationalUnitName: GlobalSign Root CA - R2
            organizationName: GlobalSign
            commonName: GlobalSign
        Validity Period
            Not Before: 2017-06-15 00:00:42
            Not After: 2021-12-15 00:00:42
        Subject
            countryName: US
            organizationName: Google Trust Services
            commonName: GTS CA 1O1
        Subject Public Key Information
            Public Key Algorithm: RSA
    Signature Algorithm: SHA-256 with RSA
    Signature: 1a803e3679fbf32ea946377d5e541635aec74e0899febdd13469265266073d0aba49cb62f4f11a8efc114f68964c742bd367deb2a3aa058d844d4c20650fa596da0d16f86c3bdb6f0423886b3a6cc160bd689f718eee2d583407f0d554e98659fd7b5e0d2194f58cc9a8f8d8f2adcc0f1af39aa7a90427f9a3c9b0ff02786b61bac7352be856fa4fc31c0cedb63cb44beaedcce13cecdc0d8cd63e9bca42588bcc16211740bca2d666efdac4155bcd89aa9b0926e732d20d6e6720025b10b090099c0c1f9eadd83beaa1fc6ce8105c085219512a71bbac7ab5dd15ed2bc9082a2c8ab4a621ab63ffd7524950d089b7adf2affb50ae2fe1950df346ad9d9cf5ca
```