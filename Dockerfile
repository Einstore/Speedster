FROM einstore/swift:latest-full as builder

WORKDIR /app
COPY . /app

ARG CONFIGURATION="debug"

RUN swift build --configuration ${CONFIGURATION} --product speedster

# ------------------------------------------------------------------------------

FROM einstore/swift:latest-full

ARG CONFIGURATION="debug"

WORKDIR /app
COPY --from=builder /app/.build/${CONFIGURATION}/speedster /app

EXPOSE 8080

ENTRYPOINT ["/app/speedster"]
CMD ["serve", "--hostname", "0.0.0.0", "--port", "8080"]
