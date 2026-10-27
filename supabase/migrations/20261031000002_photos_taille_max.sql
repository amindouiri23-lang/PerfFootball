-- Images des diapositives (journal du 2026-10-27) : jusqu'à 1600 px, une photo de téléphone dépasse la
-- limite de 512 Ko pensée pour les photos de profil (512 px). Limite portée à 5 Mo ; seuls les formats
-- d'image restent acceptés (JPEG, PNG, WebP).
update storage.buckets set file_size_limit = 5242880 where id = 'photos';
