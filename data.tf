data "external" "zip_lambda_minecraft" {
	program = ["bash", "-c", <<EOT
# Wrong: don't return an absolute path!

(cd lambda_minecraft && zip -FSr /tmp/lambda_minecraft.zip .) >&2 && echo "{\"dest\": \"$(pwd)/connection/minecraft\"}"
EOT
]
	working_dir = path.module
}
