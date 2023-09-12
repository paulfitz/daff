## Java

In order to publish `daff` to Maven Central, the file `~/.jreleaser/config.properties` with the following contents is required:

```bash
JRELEASER_NEXUS2_USERNAME="<your-sonatype-account-username>"
JRELEASER_NEXUS2_PASSWORD="<your-sonatype-account-password>"
JRELEASER_GPG_PASSPHRASE="<your-pgp-passphrase>"
JRELEASER_GPG_PUBLIC_KEY="/path/to/public.gpg"
JRELEASER_GPG_SECRET_KEY="/path/to/private.gpg"
JRELEASER_GITHUB_TOKEN="<your-github-token>"
```

In order to get a Sonatype account, follow [the steps in this guide](https://maciejwalkowiak.com/blog/guide-java-publish-to-maven-central/).

The GPG public key has to be published to a key server:

```bash
gpg --keyserver keyserver.ubuntu.com --send-keys <key id>
```

The public and private keys can be exported to files with the following commands:

```bash
gpg --output public.pgp --armor --export username@email-host
gpg --output private.pgp --armor --export-secret-key username@email-host
```

The GitHub token can be generated in GitHub/User Profile/Settings/Developer settings.

Once all configuration is in place, execute the following commands from the directory `java_bin/daff` (from JReleaser's [docs](https://jreleaser.org/guide/latest/examples/maven/maven-central.html)):

1) Verify release & deploy configuration

```bash
mvn jreleaser:config
```

2) Stage all artifacts to a local directory

```bash
mvn -Ppublication
```

3) Deploy and release

```bash
mvn jreleaser:full-release
```
