# TrenSaham

[![Laravel](https://img.shields.io/badge/Laravel-8.x-red?logo=laravel&logoColor=white)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-%5E7.3%20%7C%20%5E8.0-777BB4?logo=php&logoColor=white)](https://www.php.net/)
[![License](https://img.shields.io/github/license/abewartech/TrenSaham)](LICENSE)
[![Build Status](https://img.shields.io/github/actions/workflow/status/abewartech/TrenSaham/tests.yml?branch=main&label=tests)](https://github.com/abewartech/TrenSaham/actions)

TrenSaham is a Laravel-based web application that helps users explore and analyze stock trends with an intuitive, web-based interface.  
It aggregates data from multiple sources and surfaces insights in a clean, modern UI so users can quickly understand market movements.

![TrenSaham Banner](https://raw.githubusercontent.com/abewartech/TrenSaham/main/public/trensahambyabe.png?raw=true)

<!-- GitAds Sponsored -->
[![Sponsored by GitAds](https://gitads.dev/v1/ad-serve?source=abewartech/trensaham@github)](https://gitads.dev/v1/ad-track?source=abewartech/trensaham@github)
<!-- GitAds-Verify: D5MJ9AAT2C9X8K3427AP4YBZM9YR8MT1 -->

---

## Features

- 📈 Stock trend visualization and analysis
- 🔍 Aggregation of stock information from external APIs and data providers
- ⚡ Fast, responsive interface powered by Laravel and React
- 🔐 Environment-based configuration for secure API keys and credentials
- 🧪 PHPUnit test setup for backend code
- 📦 Ready-to-use build pipeline with Laravel Mix

## Screenshots

| ![Screenshot 1](screenshots/screen1.png) | ![Screenshot 2](screenshots/screen2.png) | ![Screenshot 3](screenshots/screen3.png) |
|:---:|:---:|:---:|
| *Dashboard overview* | *Stock detail view* | *Search and filtering* |

> Note: The paths above assume screenshots are stored under `screenshots/` in the project root.

## Installation

### Prerequisites

- PHP `^7.3` or `^8.0`
- Composer
- Node.js and npm
- A supported database (e.g. MySQL)

### Steps

Clone the repository:

```bash
git clone https://github.com/abewartech/TrenSaham.git
cd TrenSaham
```

Install PHP dependencies:

```bash
composer install
```

Install frontend dependencies:

```bash
npm install
```

Create your environment configuration:

```bash
cp .env.example .env
php artisan key:generate
```

Configure your `.env` file with database credentials and any required API keys, then run migrations:

```bash
php artisan migrate
```

Build frontend assets (development):

```bash
npm run dev
```

Or build for production:

```bash
npm run prod
```

## Usage

Start the local development server:

```bash
php artisan serve
```

By default, the application will be available at `http://127.0.0.1:8000`.

### Example: Running tests

```bash
phpunit
# or
php artisan test
```

### Example: Rebuilding assets while developing

```bash
npm run watch
```

This will watch your assets and automatically recompile them when files change.

## Project Structure

A brief overview of the main project components:

```text
.
├─ app/               # Application core (models, controllers, services)
├─ bootstrap/         # Framework bootstrap files
├─ config/            # Application configuration files
├─ database/          # Migrations, factories, seeders
├─ public/            # Public web root (entry point, public assets)
├─ resources/         # Blade views, React components, SASS, JS
├─ routes/            # Route definitions (web, api, console)
├─ storage/           # Logs, cached views, compiled files
├─ tests/             # Automated tests
├─ webpack.mix.js     # Laravel Mix configuration
├─ composer.json      # PHP dependencies and metadata
└─ package.json       # Node / frontend tooling configuration
```

## Technologies

**Backend**

- ![Laravel](https://img.shields.io/badge/Laravel-8.x-red?logo=laravel&logoColor=white)
- ![PHP](https://img.shields.io/badge/PHP-%5E7.3%20%7C%20%5E8.0-777BB4?logo=php&logoColor=white)
- ![Guzzle](https://img.shields.io/badge/Guzzle_HTTP-7.x-0A0A0A)

**Frontend / Build**

- ![React](https://img.shields.io/badge/React-17-61DAFB?logo=react&logoColor=black)
- ![Sass](https://img.shields.io/badge/Sass-1.x-CC6699?logo=sass&logoColor=white)
- ![Laravel Mix](https://img.shields.io/badge/Laravel%20Mix-6.x-1F9CF0)

**Tooling**

- ![Composer](https://img.shields.io/badge/Composer-PHP%20dependencies-885630?logo=composer&logoColor=white)
- ![npm](https://img.shields.io/badge/npm-frontend%20tooling-CB3837?logo=npm&logoColor=white)
- ![PHPUnit](https://img.shields.io/badge/PHPUnit-9.x-777BB4)

## Contributing

Contributions are welcome and appreciated.

1. Fork the repository
2. Create a new branch for your feature or fix (`git checkout -b feature/my-new-feature`)
3. Make your changes and add tests where appropriate
4. Run the test suite to ensure everything passes
5. Commit your changes with a clear message
6. Push the branch to your fork
7. Open a Pull Request describing your changes

Please follow existing code style conventions and keep pull requests focused on a single topic.

## License

This project is open-sourced software licensed under the [MIT license](LICENSE).



