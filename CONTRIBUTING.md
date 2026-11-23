# Contributing Guide

## Project Architecture
The project follows Clean Architecture + Feature-First structure:
- Each feature has 3 layers: data / domain / presentation
- Shared code lives in lib/core

## Adding a New Feature
Copy the structure of lib/features/auth as a template, starting from domain/entities.

## Branch Naming
- feature/feature-name  (example: feature/login-screen)
- fix/issue-name
- refactor/part-name

## Commit Rules
- Use clear messages, e.g.: "feat: add login screen"
- Never push directly to main; always use a Pull Request

## Before Opening a Pull Request
- Make sure `flutter analyze` runs with no errors
- Make sure your code follows the shared UseCase and Failure base classes from core
