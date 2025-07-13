source /usr/share/cachyos-fish-config/cachyos-config.fish
zoxide init fish | source
alias l 'ls -lah'
alias cd z
alias nv nvim
alias vn nvim
alias mr rm
alias vim nvim
alias vi nvim
alias nano nvim
alias dotnet_run_https 'dotnet run --launch-profile https'
set -x Kestrel__Certificates__Default__Path "/home/sk/.dotnet/corefx/cryptography/x509stores/my/875E3FD1CCD3F965D6D8AFC9A9CA3D8344AD30E9.pfx"
set -x GOOGLE_GENAI_USE_VERTEXAI true

# The next line updates PATH for the Google Cloud SDK.
if test -f /home/sk/.gemini/google-cloud-sdk/path.fish.inc
    source /home/sk/.gemini/google-cloud-sdk/path.fish.inc
end

# The next line enables shell command completion for gcloud.
if test -f /home/sk/.gemini/google-cloud-sdk/completion.fish.inc
    source /home/sk/.gemini/google-cloud-sdk/completion.fish.inc
end
