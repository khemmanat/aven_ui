# Fix Instructions for Your Test Project

Run these commands in your test project directory:

```bash
# Clean the cached dependency
mix deps.clean aven_ui --build

# Update the dependency to get the latest changes
mix deps.get

# Force recompile the dependency
mix deps.compile aven_ui --force

# Then try your assets setup
mix assets.setup
```

This will ensure you're using the latest version with the fix applied.
