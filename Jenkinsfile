#!/usr/bin/env groovy

library("govuk")

node('mongodb-2.4') {
  govuk.buildProject(
    beforeTest: { sh("yarn install") },
    sassLint: false,
  )
}
