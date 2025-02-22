-- Show version in logs
SCRIPT_VERSION = GetResourceMetadata(GetCurrentResourceName(), 'version')
print(('Script version %s started'):format(SCRIPT_VERSION))