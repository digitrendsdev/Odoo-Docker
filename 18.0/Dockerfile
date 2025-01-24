# Stage 1: Builder stage to install dependencies and build Odoo
FROM python:3.9-slim as builder

# Set environment variables
ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    node-less \
    npm \
    wkhtmltopdf \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss for right-to-left language support
RUN npm install -g rtlcss

# Install Odoo Python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip install --user -r /tmp/requirements.txt

# Stage 2: Final stage to create a lightweight Odoo image
FROM python:3.9-slim

# Set environment variables
ENV LANG=C.UTF-8 \
    ODOO_RC=/etc/odoo/odoo.conf \
    DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    libxml2 \
    libxslt1.1 \
    libldap-2.4-2 \
    libsasl2-2 \
    fonts-noto-cjk \
    wkhtmltopdf \
    && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from the builder stage
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# Create Odoo user and directories
RUN useradd -m -d /opt/odoo -U -r -s /bin/bash odoo \
    && mkdir -p /var/lib/odoo \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo:odoo /var/lib/odoo /mnt/extra-addons

# Copy Odoo configuration file
COPY ./odoo.conf /etc/odoo/odoo.conf
RUN chown odoo:odoo /etc/odoo/odoo.conf

# Copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set up volumes for persistent data
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo ports
EXPOSE 8069 8071 8072

# Set the default user
USER odoo

# Entrypoint and default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
