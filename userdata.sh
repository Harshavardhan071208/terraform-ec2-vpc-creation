
#!/bin/bash

set -Eeuo pipefail

# ==========================================
# DevOps World - Automated Website Deployment
# Supported OS: Amazon Linux 2023, Ubuntu
# ==========================================

LOG_FILE="/var/log/devops-deploy.log"

# Log all output
exec > >(tee -a "$LOG_FILE") 2>&1

trap 'echo "ERROR: Deployment failed at line $LINENO. Check $LOG_FILE"' ERR

echo "=========================================="
echo "       DEVOPS WORLD WEBSITE DEPLOYER"
echo "=========================================="

# Check root permissions
if [ "$EUID" -ne 0 ]; then
    echo "Run with: sudo bash deploy.sh"
    exit 1
fi

# ------------------------------------------
# Detect operating system and install Nginx
# ------------------------------------------

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot detect Linux distribution."
    exit 1
fi

case "${ID:-}" in
    ubuntu|debian)
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get install -y nginx curl
        WEBROOT="/var/www/html"
        ;;
    amzn|rhel|rocky|almalinux|fedora)
        if command -v dnf >/dev/null 2>&1; then
            dnf install -y nginx curl
        else
            yum install -y nginx curl
        fi
        WEBROOT="/usr/share/nginx/html"
        ;;
    *)
        echo "Unsupported OS: ${PRETTY_NAME:-unknown}"
        exit 1
        ;;
esac

echo "Operating system: ${PRETTY_NAME:-$ID}"
echo "Website directory: $WEBROOT"

# ------------------------------------------
# Create website directory
# ------------------------------------------

mkdir -p "$WEBROOT"

# ------------------------------------------
# Get EC2 Instance ID if running on AWS
# ------------------------------------------

INSTANCE_ID="Local Linux Machine"

TOKEN=$(curl -sS --connect-timeout 2 --max-time 3 \
    -X PUT \
    "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 60" \
    2>/dev/null || true)

if [ -n "$TOKEN" ]; then
    INSTANCE_ID=$(curl -sS --connect-timeout 2 --max-time 3 \
        -H "X-aws-ec2-metadata-token: $TOKEN" \
        "http://169.254.169.254/latest/meta-data/instance-id" \
        2>/dev/null || echo "Unknown")
fi

# ------------------------------------------
# Generate DevOps World Website
# ------------------------------------------

cat > "$WEBROOT/index.html" <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="theme-color" content="#080d1b">
<meta name="description" content="Explore Linux, AWS, Docker, Kubernetes, CI/CD and DevOps engineering.">

<title>DevOps World | Build the Future</title>

<style>
:root {
    --bg: #080d1b;
    --panel: #111b30;
    --blue: #38bdf8;
    --purple: #8b5cf6;
    --text: #f8fafc;
    --muted: #b8c5dc;
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    scroll-behavior: smooth;
}

body {
    font-family: Arial, sans-serif;
    background: var(--bg);
    color: var(--text);
    line-height: 1.7;
}

nav {
    position: sticky;
    top: 0;
    z-index: 10;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 18px 8%;
    background: rgba(12, 19, 38, .95);
    border-bottom: 1px solid #243451;
    backdrop-filter: blur(12px);
}

.logo {
    color: var(--blue);
    font-size: 25px;
    font-weight: bold;
}

nav a {
    color: var(--text);
    text-decoration: none;
    margin-left: 22px;
    transition: color .2s;
}

nav a:hover {
    color: var(--blue);
}

.hero {
    min-height: 80vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 70px 20px;
    background:
        radial-gradient(ellipse at 50% 0%, #243a79 0%, transparent 65%),
        var(--bg);
}

.eyebrow {
    color: var(--blue);
    letter-spacing: 3px;
    text-transform: uppercase;
    margin-bottom: 18px;
    font-size: 13px;
    font-weight: bold;
}

.hero h1 {
    font-size: clamp(40px, 7vw, 76px);
    line-height: 1.15;
    margin-bottom: 24px;
}

.hero h1 span {
    background: linear-gradient(90deg, var(--blue), var(--purple));
    -webkit-background-clip: text;
    background-clip: text;
    color: transparent;
}

.hero p {
    max-width: 680px;
    color: var(--muted);
    font-size: 18px;
    margin-bottom: 32px;
}

.btn {
    display: inline-block;
    background: linear-gradient(90deg, #0284c7, #7c3aed);
    color: white;
    padding: 14px 28px;
    border-radius: 10px;
    text-decoration: none;
    font-weight: bold;
    transition: transform .2s, box-shadow .2s;
}

.btn:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 30px #0284c755;
}

section {
    padding: 75px 8%;
    text-align: center;
}

.section-label {
    color: var(--blue);
    text-transform: uppercase;
    letter-spacing: 2px;
    font-size: 12px;
    font-weight: bold;
}

section h2 {
    font-size: clamp(28px, 4vw, 40px);
    margin: 10px 0 35px;
}

.cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 22px;
}

.card {
    padding: 30px 24px;
    background: linear-gradient(145deg, #14203a, #0d1528);
    border: 1px solid #243451;
    border-radius: 16px;
    transition: transform .25s, border-color .25s;
    text-align: left;
}

.card:hover {
    transform: translateY(-7px);
    border-color: var(--blue);
}

.card .emoji {
    font-size: 32px;
    margin-bottom: 12px;
}

.card h3 {
    color: var(--blue);
    margin-bottom: 10px;
    font-size: 21px;
}

.card p {
    color: var(--muted);
    font-size: 15px;
}

.about-box {
    max-width: 850px;
    margin: auto;
    padding: 35px;
    background: var(--panel);
    border: 1px solid #243451;
    border-radius: 18px;
}

.server {
    margin-top: 22px;
    color: var(--muted);
    font-size: 13px;
    overflow-wrap: anywhere;
}

.server strong {
    color: #4ade80;
}

footer {
    text-align: center;
    padding: 26px;
    color: #94a3b8;
    background: #0c1326;
    border-top: 1px solid #243451;
}

@media (max-width: 650px) {
    nav {
        flex-direction: column;
        gap: 10px;
    }

    nav a {
        margin: 0 8px;
        font-size: 14px;
    }

    section {
        padding: 55px 6%;
    }
}

@media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        scroll-behavior: auto !important;
        transition: none !important;
    }
}
</style>
</head>

<body>

<nav>
    <div class="logo">DevOps World</div>
    <div>
        <a href="#home">Home</a>
        <a href="#services">Services</a>
        <a href="#about">About</a>
    </div>
</nav>

<main>
<section class="hero" id="home">
    <div class="eyebrow">Automate · Innovate · Scale</div>
    <h1>Build. Deploy.<br><span>Innovate.</span></h1>
    <p>
        Discover Linux, cloud computing, automation and modern
        DevOps engineering. Build reliable infrastructure and
        turn your ideas into reality.
    </p>
    <a class="btn" href="#services">Explore Technologies →</a>
</section>

<section id="services">
    <div class="section-label">Our Expertise</div>
    <h2>Explore Our Technologies</h2>

    <div class="cards">
        <article class="card">
            <div class="emoji">🐧</div>
            <h3>Linux</h3>
            <p>Master shell scripting, system administration,
            permissions and automation.</p>
        </article>

        <article class="card">
            <div class="emoji">☁️</div>
            <h3>AWS Cloud</h3>
            <p>Build scalable cloud infrastructure with EC2,
            VPC, S3 and load balancing.</p>
        </article>

        <article class="card">
            <div class="emoji">🐳</div>
            <h3>Docker</h3>
            <p>Package applications into portable containers
            and simplify deployments.</p>
        </article>

        <article class="card">
            <div class="emoji">⚙️</div>
            <h3>CI/CD</h3>
            <p>Automate builds, testing and delivery using
            continuous integration pipelines.</p>
        </article>

        <article class="card">
            <div class="emoji">☸️</div>
            <h3>Kubernetes</h3>
            <p>Deploy, orchestrate and scale containerized
            applications reliably.</p>
        </article>

        <article class="card">
            <div class="emoji">📊</div>
            <h3>Monitoring</h3>
            <p>Track infrastructure health, metrics and
            application performance.</p>
        </article>

        <article class="card">
            <div class="emoji">🏗️</div>
            <h3>Terraform</h3>
            <p>Provision and manage repeatable infrastructure
            using infrastructure as code.</p>
        </article>

        <article class="card">
            <div class="emoji">🔐</div>
            <h3>DevSecOps</h3>
            <p>Integrate security checks and safer practices
            throughout delivery pipelines.</p>
        </article>
    </div>
</section>

<section id="about">
    <div class="section-label">Our Mission</div>
    <h2>Automate Your Future</h2>

    <div class="about-box">
        <p>
            Learn, experiment and build real-world cloud
            infrastructure with Linux, AWS and DevOps.
            Every great deployment starts with automation.
        </p>

        <div class="server">
            Running on instance:
            <strong>${INSTANCE_ID}</strong>
        </div>
    </div>
</section>
</main>

<footer>
    © 2026 DevOps World | Powered by Linux, Nginx & Terraform
</footer>

</body>
</html>
HTML

# ------------------------------------------
# Validate Nginx configuration
# ------------------------------------------

nginx -t

# ------------------------------------------
# Enable and start Nginx
# ------------------------------------------

if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now nginx
    systemctl restart nginx
else
    service nginx restart
fi

# ------------------------------------------
# Verify deployment
# ------------------------------------------

echo "Checking local HTTP response..."

for attempt in {1..10}; do
    if curl --fail --silent --show-error \
        http://127.0.0.1/ >/dev/null; then
        break
    fi

    if [ "$attempt" -eq 10 ]; then
        echo "Website did not respond successfully."
        exit 1
    fi

    sleep 2
done

echo ""
echo "=========================================="
echo " WEBSITE DEPLOYED SUCCESSFULLY"
echo "=========================================="
echo "OS: $PRETTY_NAME"
echo "Web root: $WEBROOT"
echo "Instance ID: $INSTANCE_ID"
echo "Local URL: http://localhost"
echo "Log file: $LOG_FILE"
echo "=========================================="


