namespace IDelivery.Application.Services;

public static class ProductImagePath
{
    public static string? Normalize(string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) return null;

        var imagePath = value.Trim();
        if (Uri.TryCreate(imagePath, UriKind.Absolute, out var uri))
        {
            if (uri.Scheme is not ("http" or "https"))
                throw new InvalidOperationException("ImageUrl deve usar http ou https.");
            return imagePath;
        }

        imagePath = imagePath.Replace('\\', '/');
        if (imagePath.Contains("..", StringComparison.Ordinal))
            throw new InvalidOperationException("ImageUrl nao pode conter caminho relativo inseguro.");

        imagePath = "/" + imagePath.TrimStart('/');
        if (!imagePath.StartsWith("/uploads/", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Caminho relativo de imagem deve iniciar com /uploads/.");

        return imagePath;
    }
}
