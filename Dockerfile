FROM einstore/swift:latest-full as builder

WORKDIR /app
COPY . /app

ARG CONFIGURATION="debug"

RUN swift build --configuration ${CONFIGURATION} --product speedster

# ------------------------------------------------------------------------------

FROM einstore/swift:latest-full

ARG CONFIGURATION="debug"

ENV PERSONAL_ACCESS_TOKEN=""
ENV DB="postgres"
ENV SECRET="c3BlZWRzdGVyOtq39S8PBthwDkJ0m2S/OBJtvZE4viY0xA726hgLKcIC"

WORKDIR /app
COPY --from=builder /app/.build/${CONFIGURATION}/speedster /app

EXPOSE 8080

ENTRYPOINT ["/app/speedster"]
CMD ["serve", "--hostname", "0.0.0.0", "--port", "8080", "--auto-migrate"]
