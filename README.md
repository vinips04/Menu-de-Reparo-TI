# Windows Diagnostic Toolkit

Interactive Batch toolkit for Windows diagnostics, troubleshooting, maintenance and infrastructure support tasks.

The project centralizes common operational commands in a guided menu, validates administrator privileges when required and records each execution in a local log.

## Features

### System diagnostics

- Online scan of the system drive with CHKDSK
- Protected system file scan and repair with SFC
- System information collection and TXT export

### Network troubleshooting

- Connectivity test against a fixed IP address
- Detailed network configuration display with IPCONFIG
- DNS resolver cache cleanup

### Maintenance

- Confirmed cleanup of the current user's temporary directory
- Export of installed third-party drivers
- Timestamped operation logs with command output and exit codes
- Administrator status detection and per-operation privilege checks

## Requirements

- Windows 10 or Windows 11
- Windows Command Prompt
- PowerShell, included with supported Windows versions, for locale-independent timestamps
- Administrator privileges for CHKDSK, SFC, DNS cache cleanup and driver backup

No third-party dependencies are required.

## Project Structure

```text
windows-diagnostic-toolkit/
├── scripts/
│   └── windows-diagnostic-toolkit.bat
├── .gitattributes
├── .gitignore
├── LICENSE
└── README.md
```

The toolkit creates the following directories during execution:

```text
logs/                 Timestamped execution logs
backups/drivers/      Exported third-party drivers
reports/              System information reports
```

Runtime output is ignored by Git and remains on the local computer.

## How to Use

Clone the repository:

```bash
git clone https://github.com/vinips04/windows-diagnostic-toolkit.git
```

Open the scripts directory:

```cmd
cd windows-diagnostic-toolkit\scripts
```

Run the toolkit:

```cmd
windows-diagnostic-toolkit.bat
```

For access to every option, right-click the Batch file and select **Run as administrator**. The menu remains available without elevation, but protected operations are blocked individually.

## Available Options

```text
[1] Scan System Drive (CHKDSK)
[2] Repair System Files (SFC)
[3] Clean Current User Temporary Files
[4] Test Network Connectivity (Ping)
[5] Display Network Configuration
[6] Flush DNS Cache
[7] Backup Installed Drivers
[8] Export System Information
[0] Exit
```

## Runtime Behavior

- CHKDSK uses `/scan` against `%SystemDrive%`; it performs an online scan and does not schedule an offline repair.
- SFC uses `/scannow` and may repair protected Windows files.
- Temporary-file cleanup requires explicit confirmation and is limited to the validated `%TEMP%` directory of the current user. Locked files may remain.
- The connectivity test sends four ICMP echo requests to `8.8.8.8`.
- Driver backups and system reports are written inside the project directory.
- Command output and exit codes are recorded in one log file per toolkit session.

## Security Notes

- The script stores no credentials and downloads no external content.
- It uses only tools included with supported Windows versions.
- Administrative privileges are required only for protected operations.
- Logs and reports can contain computer, user, network and system details. Review them before sharing.

## License

This project is licensed under the [MIT License](LICENSE).

## Author

**Vinicius Pereira**

[LinkedIn](https://www.linkedin.com/in/viniciuspereira27/) | [GitHub](https://github.com/vinips04)

`vinips04` • *Every trace tells a story.*
