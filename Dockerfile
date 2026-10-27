# Build context: root of ikraammel/eBus_frontend (contains eBus_front/pubspec.yaml).
ARG FLUTTER_IMAGE=ghcr.io/cirruslabs/flutter:stable
FROM ${FLUTTER_IMAGE} AS build
WORKDIR /app
COPY eBus_front/ ./
ARG API_BASE_URL=https://ebus-backend-ao2u.onrender.com
# Fail rather than silently produce a frontend tied to the Android emulator API.
RUN grep -q 'String.fromEnvironment' lib/constants/constants.dart \
 && grep -q 'API_BASE_URL' lib/constants/constants.dart \
 && flutter pub get \
 && flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginxinc/nginx-unprivileged:stable-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 8080
