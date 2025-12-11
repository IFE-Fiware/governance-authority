
curl -X POST "$AUTHORITY_AUTH_PROVIDER/v1/keypairs/generate"

# Generating CSR
curl -X POST "$AUTHORITY_AUTH_PROVIDER/v1/csr/generate" \
--header 'Content-Type: application/json' \
--data-raw '{
  "commonName": "tls-authority-ds.fiware.ife.no",  "country": "NO",  "organization": "IFE", "organizationalUnit": "Nuclear"
}' > csr.pem

# Creating Authority participant
PARTICIPANT_ID=$(curl -X POST "$AUTHORITY_IDENTITY_PROVIDER/v1/participants" \
--header 'Content-Type: application/json' \
--data-raw '{
  "organization": "IFE",
  "participantType": "GOVERNANCE_AUTHORITY"
}' | sed -E 's/^"(.*)"$/\1/')

# Uploading CSR 
curl -X POST "$AUTHORITY_IDENTITY_PROVIDER/v1/participants/$PARTICIPANT_ID/csr" \
-F "csr=@/Users/per.arne.jorgensenife.no/csr.pem"

# Downloading credentials 
curl "$AUTHORITY_IDENTITY_PROVIDER/v1/credentials/$PARTICIPANT_ID/download" \
-o cert.pem

# Uploading credentials ...
curl -X POST "$AUTHORITY_AUTH_PROVIDER/v1/credentials" \
-F "credential=@/Users/per.arne.jorgensenife.no/cert.pem"

curl -X POST "$AUTHORITY_AUTH_PROVIDER/v1/credentials" -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0ZjVmY2ZhZS05NzJlLTQ5NGUtYjk1Zi02ZGI2MTU0YzU5ZTIifQ.eyJleHAiOjE3NjU0MTg2NzQsImlhdCI6MTc2NTM4MjY3NCwianRpIjoiY2RhOTMyN2UtMjAwNC00NzA3LWEzYTktNjI4YTllNjYyMGYyIiwiaXNzIjoiaHR0cHM6Ly9hdXRob3JpdHktYmUtYXV0aG9yaXR5MDEtZHMuZml3YXJlLmlmZS5uby9hdXRoL3JlYWxtcy9tYXN0ZXIiLCJzdWIiOiJhM2I4MjczOS0xNGQ0LTRmZjgtYTZjZi0wMDJiOTE5MjNkMDYiLCJ0eXAiOiJTZXJpYWxpemVkLUlEIiwic2lkIjoiYjNkNjljZjUtNTE5Yy00NmYwLTk0MGUtODAwZjgwZDBjNjRkIiwic3RhdGVfY2hlY2tlciI6IlFwRDZuclc0b0Z1bHZiUUFEY3lSenZYdVlQUDFPM0hxbGw1NzM2VXZhVzQifQ.7ON0D1B_nz_ScfN5O-g-psb1hwO8Kr7JOwqHUWF6h-qkw2ED6qXFmUkPxnAWvW5wvAbIbNBK-a6W2okU37knCQ" -F "credential=@/Users/per.arne.jorgensenife.no/cert.pem"

# Notes
# curl -X DELETE "$AUTHORITY_IDENTITY_PROVIDER/v1/participants/019b08d0-298c-7286-9911-529d9fb6839b

# PARTICIPANT_ID=$(curl -X POST "$AUTHORITY_IDENTITY_PROVIDER/v1/participants" \
# --header 'Content-Type: application/json' \
# --data-raw '{
#  "organization": "IFE",
#  "participantType": "GOVERNANCE_AUTHORITY"
# }' | sed -E 's/^"(.*)"$/\1/')

# https://authority-be-authority01-ds.fiware.ife.no/auth/admin/master/console/#/authority/users
#  admin:GJnKKEPUtGF00ClO

#JWT token fra admin brukeren hentet fra nettleseren
#  eyJhbGciOiJIUzUxMiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0ZjVmY2ZhZS05NzJlLTQ5NGUtYjk1Zi02ZGI2MTU0YzU5ZTIifQ.eyJleHAiOjE3NjU0MTg2NzQsImlhdCI6MTc2NTM4MjY3NCwianRpIjoiY2RhOTMyN2UtMjAwNC00NzA3LWEzYTktNjI4YTllNjYyMGYyIiwiaXNzIjoiaHR0cHM6Ly9hdXRob3JpdHktYmUtYXV0aG9yaXR5MDEtZHMuZml3YXJlLmlmZS5uby9hdXRoL3JlYWxtcy9tYXN0ZXIiLCJzdWIiOiJhM2I4MjczOS0xNGQ0LTRmZjgtYTZjZi0wMDJiOTE5MjNkMDYiLCJ0eXAiOiJTZXJpYWxpemVkLUlEIiwic2lkIjoiYjNkNjljZjUtNTE5Yy00NmYwLTk0MGUtODAwZjgwZDBjNjRkIiwic3RhdGVfY2hlY2tlciI6IlFwRDZuclc0b0Z1bHZiUUFEY3lSenZYdVlQUDFPM0hxbGw1NzM2VXZhVzQifQ.7ON0D1B_nz_ScfN5O-g-psb1hwO8Kr7JOwqHUWF6h-qkw2ED6qXFmUkPxnAWvW5wvAbIbNBK-a6W2okU37knCQ