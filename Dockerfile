FROM swift:5.7 as build

COPY . /build

WORKDIR /build

RUN swift package --disable-sandbox \
  --allow-writing-to-package-directory \
  update-version \
  psychrometrics-cli

RUN swift build --configuration release

FROM build

COPY --from=build /build/.build/release/psychrometrics /bin

ENTRYPOINT ["/bin/psychrometrics"]
