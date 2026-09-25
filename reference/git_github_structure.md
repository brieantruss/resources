YOUR MACHINE (bt-victus)                                   GITHUB SERVERS
=====================================================      ========================
[1. Commit Metadata]
    git config --global user.name "Briean Truss"
    git config --global user.email "briean.j.truss@..."
         │
         │  (Only stamps your name on commits.
         │   Has ZERO security power. GitHub ignores this for login.)
         ▼
[2. Local Repository] (~/dev/resources/.git)
    Contains your local commits & history.
    Stores the pointer to GitHub:
    remote.origin.url = "https://github.com/brieantruss/resources.git"
         │
         │  `git push` triggers the upload attempt...
         ▼
[3. System Credential Cache] ◄── [THIS WAS THE CULPRIT]
    Stores your saved password / token.
    It was still holding: "User: briean-arvig | Token: ghp_****"
         │
         │  Git blindly grabs this old token and sends it over HTTPS...
         ▼
══════════════════════ HTTPS NETWORK REQUEST ═════════════════════►
                                                                 │
                                                    [4. GitHub Authentication]
                                                        GitHub inspects the token:
                                                        "This token belongs to briean-arvig."
                                                                 │
                                                    [5. Repository Permissions]
                                                        GitHub checks:
                                                        "Can briean-arvig write to
                                                         brieantruss/resources?"
                                                                 │
                                                                 ▼
                                                        NO ──► 403 Forbidden!
