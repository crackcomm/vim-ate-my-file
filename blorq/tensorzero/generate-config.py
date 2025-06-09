import toml
import json


secrets = json.loads(open("secrets.json").read())

data = {"service": {"environment": secrets}}

MODELS = [
    # max output tokens: 65536
    {"name": "gemini-2.5-pro-exp-03-25", "provider": "google_ai_studio_gemini"},
    # max output tokens: 65536
    {"name": "gemini-2.5-flash-preview-05-20", "provider": "google_ai_studio_gemini"},
    # max output tokens: 8192
    {"name": "gemini-2.0-flash", "provider": "google_ai_studio_gemini"},
    # max output tokens: 8192
    {"name": "gemini-2.0-flash-lite", "provider": "google_ai_studio_gemini"},
    # max output tokens: 8192
    {"name": "gemini-1.5-flash", "provider": "google_ai_studio_gemini"},
    # max output tokens: 8192
    {"name": "gemini-1.5-flash-8b", "provider": "google_ai_studio_gemini"},
]

FUNCTIONS = [
    {"name": "extract_data", "type": "chat"},
]


def sanitize_model_name(name):
    return name.replace("-", "_").replace(".", "_")


config = {
    "models": {},
    "functions": {},
}

for function in FUNCTIONS:
    function_key = function["name"]
    config["functions"][function_key] = {
        "type": function["type"],
        "variants": {},
    }

for model in MODELS:
    provider = model["provider"]
    model_name = model["name"]
    key = sanitize_model_name(model_name)
    provider_secrets = secrets.get(provider, {})

    for n, secret_value in enumerate(provider_secrets):
        model_key = f"{key}_api_key_{n + 1}"
        api_key_location = f"env::{provider}_API_KEY_{n + 1}"
        config["models"][model_key] = {
            "routing": [provider],
            "providers": {
                provider: {
                    "type": provider,
                    "model_name": model_name,
                    "api_key_location": api_key_location,
                }
            },
        }

        for function in FUNCTIONS:
            function_key = function["name"]
            config["functions"][function_key]["variants"][model_key] = {
                "type": "chat_completion",
                "model": model_key,
                "weight": 0.5,
            }


with open("tensorzero-config.toml", "w") as f:
    f.write(toml.dumps(config))
