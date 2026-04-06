.PHONY: help install check run dev stop test clean

help:
	@echo "📚 Commandes disponibles :"
	@echo ""
	@echo "  make install     → Installer les dépendances Python"
	@echo "  make check       → Vérifier la configuration"
	@echo "  make run         → Lancer l'API en local"
	@echo "  make dev         → Lancer l'API avec rechargement auto (--reload)"
	@echo "  make test        → Tester l'API (health check)"
	@echo "  make clean       → Nettoyer les fichiers temporaires"
	@echo ""

install:
	pip install -r requirements.txt
	@echo "✅ Dépendances installées"

check:
	python3 check-setup.py

run:
	./run-local.sh

dev:
	PYTHONUNBUFFERED=1 uvicorn api:app --reload --host 127.0.0.1 --port 8000

test:
	@echo "🧪 Test du health check..."
	@curl -s http://127.0.0.1:8000/health | python3 -m json.tool || echo "⚠️  L'API n'est pas accessible"
	@echo ""
	@echo "📖 Documentation API : http://127.0.0.1:8000/docs"

clean:
	rm -f /tmp/*.wav
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	@echo "✅ Nettoyage terminé"
