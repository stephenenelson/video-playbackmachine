cpan2rpm --requires="postgresql-server, perl-DBD-Pg" --requires="perl-AppConfig, perl-Image-Imlib2, perl-Log-Log4perl, perl-POE, perl-Test-MockObject, perl-Time-Duration" --requires="perl-Video-Xine" --requires="perl-X11-FullScreen" --epilogue="install:mkdir -p %_sysconfdir/playback_machine && cp conf/playback_machine.conf conf/playback_log.conf $_sysconfdir/playback_machine/" .