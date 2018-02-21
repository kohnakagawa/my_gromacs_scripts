#!/bin/bash
sed -i -e "s/@/#/g" $(find ../ -type f -name "*.xvg")
