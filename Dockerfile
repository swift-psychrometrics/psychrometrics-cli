FROM swift:5.7 as build

COPY . /build

WORKDIR /build

RUN swift build --configuration release -Xswiftc -cross-module-optimization

FROM build

COPY --from=build /build/.build/release/psychrometrics /bin

ENTRYPOINT ["/bin/psychrometrics"]
