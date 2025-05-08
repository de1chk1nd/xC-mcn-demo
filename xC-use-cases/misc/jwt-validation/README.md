https://clouddocs.f5.com/training/community/f5xc-emea-workshop/html/class4/module3/lab1/lab1.html

curl -H "Content-Type: application/json;charset=UTF-8" --location 'https://sentence.edge.de1chk1nd.de/api/locations' --header 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkxoZHI1RjZidUdiUHpCMnp5R1FCdVdKLXNuZlRnTmF3UEFGSjMzbVo3Y1kiLCJ0eXAiOiJKV1QifQ.eyJzdWIiOiJqd3QtdGVzdCIsImp0aSI6IjIzNDE0MzUiLCJuYmYiOjE3NDIzMTU1NTksImV4cCI6MTc0MjUwNjM1OSwiaWF0IjoxNzQyMzIyNzU5LCJpc3MiOiJkZTFjaGsxbmQiLCJhdWQiOiJodHRwczovL3NlbnRlbmNlLmVkZ2UuZGUxY2hrMW5kLmRlIn0.TbU_kVRltEErhYawqSOfF_raoCOgIffKEhrfM61-W4Ch6uLS-BzKJg4yxsnsvQAKwrVUmHG43dJSK-swmKE3lI6BljwLC73Ja7w5yLjPOu4bsLxXE6WStWBZcZUdBOeLCoAxqh7LK-ZgZnTSSabXtk9PW3VMeUQ7VbzYT2ZC2a3cqd5xjpuP_KM___bpMZ6iZQdPagn6tO0DFHu9wnTKKC96X_ZmlspTiJXe-Qg9j1nGmGvjJHaxrAkGUVf_5TItEn5W3Xr5aDElGXNk5uKiq397993i9rfzri78iv7K-6Lu5kynjrtqQF88HjTHA2YQokHz0MkCE3_RXUmKjF-xEw'

# # # # # # # # # # # # # # # # #

JWKS

https://mkjwk.org/

{
    "keys": [
        {
            "kty": "RSA",
            "e": "AQAB",
            "use": "sig",
            "kid": "Lhdr5F6buGbPzB2zyGQBuWJ-snfTgNawPAFJ33mZ7cY",
            "alg": "RS256",
            "n": "gGD5MsAjBDcUIaGGUn2rnxP97CVRWoJCuzfNsHlljvCZG0ZsZga9UYVD8LE8y9-U1QCFzzcZRTQZ19DmtiTk5IlP7LTaoaj3gnIHIaZEyX9DtZu07dd-e2pgyPQ6xfYJjp_OsVrqRtSqywaB4XEtUAW-4CGWYdZ4grmtiH2ggtfatlN7m0CHsmpOGEZqbluCekFAQVEpOXEj5qa1Wzelr7YkAcYUopMh1N4ZQDkz0V6iM3GfOn3NYp-hzJf78SjbeA_YJghukpwzL82yRqyRFapmjwNyuSim9wMM_gyIqCG9D8YUvoUU0tFUjRx4X3L0mzGr8ha-zsxAJBf01tNj9w"
        }   
    ]
}

{
    "kty": "RSA",
    "e": "AQAB",
    "use": "sig",
    "kid": "Lhdr5F6buGbPzB2zyGQBuWJ-snfTgNawPAFJ33mZ7cY",
    "alg": "RS256",
    "n": "gGD5MsAjBDcUIaGGUn2rnxP97CVRWoJCuzfNsHlljvCZG0ZsZga9UYVD8LE8y9-U1QCFzzcZRTQZ19DmtiTk5IlP7LTaoaj3gnIHIaZEyX9DtZu07dd-e2pgyPQ6xfYJjp_OsVrqRtSqywaB4XEtUAW-4CGWYdZ4grmtiH2ggtfatlN7m0CHsmpOGEZqbluCekFAQVEpOXEj5qa1Wzelr7YkAcYUopMh1N4ZQDkz0V6iM3GfOn3NYp-hzJf78SjbeA_YJghukpwzL82yRqyRFapmjwNyuSim9wMM_gyIqCG9D8YUvoUU0tFUjRx4X3L0mzGr8ha-zsxAJBf01tNj9w"
}

{
    "p": "13tjXp9Lsf1eEHXUYwouvEIqclEklLyQ0kdDT6JAx2jgSyxi5Sw9dUiLSUdKQHqZvL7_3P323gCXxSa3usSZAbTvcLfP5gFINAchYMwC42I7ZPMbqMnAWN2Tv5gQ3MyTBYmQrUU5JhQ6-yzpd9TAxJwmSLKUH6Ru1gsfIwL_Zfc",
    "kty": "RSA",
    "q": "mIS3pBnDiQIR-7bbsy6fzyUbJz-bSEnTJIdBSNmANIofvwVJEpmkeb-WmQ-B8bNRLyL2DGq0OwEZHJrgsLSRdcBPylZ-9bGEQjhQX5sOreuoDbLxh1on9CrbnZAnfngTYdQo0j587Qgg6hbhatNOD6-gJZ70eO2BPSrHeh_0cgE",
    "d": "dRT78PceeGerKojfsjf-35QiDs5yBbOrHIfmRb5Riy2O1TtC_UHEQ6bgsZFTOzRrzl8tqjA8EctUjmltIE1Bm9RHWkAO7UTmhsdsDZpQPdydafHZ7tiL-A6qultThtu_F55TqZia9YJbSdJjfbH0e3jh_hNjzVMGkWK6CzNXwju_EvUp-lCv_MMUf8GYh0ZKx7tO6NV6w0yPBeWGo57baspBfHN0QyowhFxbUEQkLGgJrQLAbd5Wt9jGuMEfhvAxUgfkXZDXjNsvG58fVqlMAW1HYf3F98y6uEVlJgTeaE5Bd6LWLs5AZ6Fun1WSz7C3bvcFO3qpEPRU3d-OdvO4AQ",
    "e": "AQAB",
    "use": "sig",
    "kid": "Lhdr5F6buGbPzB2zyGQBuWJ-snfTgNawPAFJ33mZ7cY",
    "qi": "dWRT2zuK2LEqHTScZBwqw3b4SXwQj7dDPMA0CwgH_3hrqeGrZt0XHT9TpiXtFH7qvKpMXIJj4K7MN3n6axg6VpXPVVQCm6HbtlMdSf_VJ1YpVEN2PIN5VwSS1_GTsIg6Ru8ySrPACGN3LlfAHN5a3e8L_1JfyE-mVFhJDR-6YwA",
    "dp": "uRCx8WxieIWgqgZo2H7AUNOK3Q-vmUayIsctmlFBzYHXUPjYHvd1-SrK5a6iqOoi66Ym3cgIo_ZiYuKz3WZH-t1I38ged-4V8wlEs3vD50JQvIzG7poH5sq2wFB7-waAJrtVVFslj_zEA0E5ar-Ap9tsTfeBnAN_Zbm7jjhe3VU",
    "alg": "RS256",
    "dq": "FEK9Kn2Jri-qN-gIs3rkG95wBvy6IhY8iEO3dnf-Qfx_Tx7ioCfs44eB9_9JYdRSWpKoYOnj21q__T7NzmuOTzgm4VgwMW9NhIZ6ltjAUHZXssosr7BYUmVHG11FAdXtrTdD3PoUGmDUDoTPmSNM4WSRP64oB9B1NKz0JtML5AE",
    "n": "gGD5MsAjBDcUIaGGUn2rnxP97CVRWoJCuzfNsHlljvCZG0ZsZga9UYVD8LE8y9-U1QCFzzcZRTQZ19DmtiTk5IlP7LTaoaj3gnIHIaZEyX9DtZu07dd-e2pgyPQ6xfYJjp_OsVrqRtSqywaB4XEtUAW-4CGWYdZ4grmtiH2ggtfatlN7m0CHsmpOGEZqbluCekFAQVEpOXEj5qa1Wzelr7YkAcYUopMh1N4ZQDkz0V6iM3GfOn3NYp-hzJf78SjbeA_YJghukpwzL82yRqyRFapmjwNyuSim9wMM_gyIqCG9D8YUvoUU0tFUjRx4X3L0mzGr8ha-zsxAJBf01tNj9w"
}

Token:
https://joaoalmeida.outsystemscloud.com/JWT_Demo/GenerateToken_JWK.aspx?(Not.Licensed.For.Production)=

eyJhbGciOiJSUzI1NiIsImtpZCI6IkxoZHI1RjZidUdiUHpCMnp5R1FCdVdKLXNuZlRnTmF3UEFGSjMzbVo3Y1kiLCJ0eXAiOiJKV1QifQ.eyJzdWIiOiJqd3QtdGVzdCIsImp0aSI6IjIzNDE0MzUiLCJuYmYiOjE3NDIzMTU1NTksImV4cCI6MTc0MjUwNjM1OSwiaWF0IjoxNzQyMzIyNzU5LCJpc3MiOiJkZTFjaGsxbmQiLCJhdWQiOiJodHRwczovL3NlbnRlbmNlLmVkZ2UuZGUxY2hrMW5kLmRlIn0.TbU_kVRltEErhYawqSOfF_raoCOgIffKEhrfM61-W4Ch6uLS-BzKJg4yxsnsvQAKwrVUmHG43dJSK-swmKE3lI6BljwLC73Ja7w5yLjPOu4bsLxXE6WStWBZcZUdBOeLCoAxqh7LK-ZgZnTSSabXtk9PW3VMeUQ7VbzYT2ZC2a3cqd5xjpuP_KM___bpMZ6iZQdPagn6tO0DFHu9wnTKKC96X_ZmlspTiJXe-Qg9j1nGmGvjJHaxrAkGUVf_5TItEn5W3Xr5aDElGXNk5uKiq397993i9rfzri78iv7K-6Lu5kynjrtqQF88HjTHA2YQokHz0MkCE3_RXUmKjF-xEw

eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImUyYmI0MTJiODNmZmQwNDJjOTczYmFmNmE4MmFlNGQyIn0.eyJpc3MiOiJGNVhDIEpXVCBkZW1vIiwic3ViIjoic2FAZjUuY29tIiwiYXVkIjoibXlsYi1mNXhjLmY1c2UuY29tIiwiaWF0IjoxNzEzNTM4NTAxLCJleHAiOjE5ODUyNjg2MzQsIkdpdmVuTmFtZSI6IkJvYiIsIkxhc3ROYW1lIjoiVGhlU3BvbmdlIiwiRW1haWwiOiJib2JAZjUuY29tIiwiUm9sZSI6IlNBIn0.WA7_DP40VK1kP76-S68qxadnTyRnaKXX9QvRL5Jhhq9tIJdNE8ULY27JY8-lpJ69F2Ne1bupoKv5Eu3QSWjOK5Etqe_pfqKhN_Yh5iyG7TmAE95h1yqehuRnPsvjaMXju7MY0nl_SGe774eXScOs-8GzkdXOVp--GMbERWsEjHTkbBlVrT4Mp2DmI3I7gKJoFGkYeSCf3MLI0rrIqMNzqrCy4cWoO2_Ttm17pfmDzcHgeyuYwN1p4m5Unq9_0SLIIg_CbrQLev2bKzft_n_-VWZaPz1VI1paqCeah5r7QIrTRRJjCJPGR9SSTMia8gvqnlDO5nnDami7y431VooiNwII5M3GVO9Uw7WHUw7lHG0HBfsvknC6-hfQbws-I5X3DhU2suKhCl_cNrST9nHLDS49uaF5c75yAEpUWgfukqQbZmaHvu7itFX8LoC1qhQWIHtFj-pkAvFTR82YwLsi8RrpGp4UNvUjxiISfXOr_SyvEvtp4wal2CMHIHea3bSv



curl -H "Content-Type: application/json;charset=UTF-8" --location 'https://api.edge.de1chk1nd.de/api/locations' --header 'Authorization: Bearer '
curl -H "Content-Type: application/json;charset=UTF-8" --location 'https://sentence.edge.de1chk1nd.de/api/locations' --header 'Authorization: Bearer '
