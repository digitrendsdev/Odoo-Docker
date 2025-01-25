# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04 as builder

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
    libldap-common \
    libldap-2.5-0 \
    libsasl2-dev \
    libssl-dev \
    node-less \
    npm \
    wkhtmltopdf \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss for right-to-left language support
RUN npm install -g rtlcss

# Install Odoo Python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --user -r /tmp/requirements.txt

# Stage 2: Final stage to create a lightweight Odoo image
FROM ubuntu:22.04

# Set environment variables
ENV LANG=C.UTF-8 \
    ODOO_RC=/etc/odoo/odoo.conf \
    DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    libxml2 \
    libxslt1.1 \
    libldap-common \
    libldap-2.5-0 \
    libsasl2-2 \
    fonts-noto-cjk \
    wkhtmltopdf \
    python3 \
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

# Expose Odoo ports
EXPOSE 8069 8071 8072

# Set the default user
USER odoo

# Entrypoint and default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
